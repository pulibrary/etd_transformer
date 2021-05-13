# frozen_string_literal: true

require 'fileutils'
require 'shellwords'

module EtdTransformer
  ##
  # Orchestrate the transformation of a Vireo export into something else
  class Transformer
    attr_reader :input_dir, :output_dir, :department, :vireo_export, :dataspace_import, :embargo_spreadsheet

    # How close must two titles be to each other, in terms of Levenshtein distance,
    # in order for us to consider them a match?
    # https://en.wikipedia.org/wiki/Levenshtein_distance
    TITLE_MATCH_THRESHOLD = 10

    ##
    # Convenience method for kicking off a transformation.
    # @param [Hash] options
    # @return [EtdTransformer::Transformer]
    # @example
    #  EtdTransformer::Transformer.transform(input: '/foo', output: '/bar')
    def self.transform(options)
      transformer = EtdTransformer::Transformer.new(options)
      transformer.transform
      transformer
    end

    ##
    # Accept an options hash as passed from Thor and configure a transformation.
    # @param [Hash] options
    def initialize(options)
      @input_dir = options[:input]
      @output_dir = options[:output]
      @embargo_spreadsheet = options[:embargo_spreadsheet]
      @department = @input_dir.split('/').last
      @vireo_export = EtdTransformer::Vireo::Export.new(@input_dir)
      @dataspace_import = EtdTransformer::Dataspace::Import.new(@output_dir, @department)
      @embargo_data = {}
      @walk_in_data = {}
    end

    ##
    # Orchestrate the transformation of a Vireo::Export
    def transform
      dataspace_submissions.each do |ds|
        copy_license_file(ds)
        process_pdf(ds)
        vs = @vireo_export.approved_submissions[ds.id]
        generate_metadata_pu(vs, ds)
        puts ds.id
      end
    end

    def dataspace_submissions
      @dataspace_submissions ||= create_dataspace_submissions
    end

    ##
    # Create a directory and an EtdTransformer::Dataspace::Submission object for each
    # approved Vireo submission
    # @return [Array]
    def create_dataspace_submissions
      @dataspace_submissions = []
      @vireo_export.approved_submissions.each_pair do |_k, v|
        dataspace_submission = EtdTransformer::Dataspace::Submission.new(@dataspace_import, v.id)
        @dataspace_submissions << dataspace_submission
        FileUtils.mkdir_p dataspace_submission.directory_path
      end
      @dataspace_submissions
    end

    ##
    # Copy LICENSE.txt file from vireo submission to dataspace submission
    def copy_license_file(dataspace_submission)
      vs = @vireo_export.approved_submissions[dataspace_submission.id]
      license_filename = 'LICENSE.txt'
      original_license = File.join(vs.source_files_directory, license_filename)
      destination_path = File.join(dataspace_submission.directory_path, license_filename)
      FileUtils.cp(original_license, destination_path)
    end

    ##
    # Full path to the thesis cover page
    def cover_page_full_path
      File.expand_path(File.join(File.dirname(__FILE__), '..', 'assets', 'SeniorThesisCoverPage.pdf'))
    end

    ##
    # Process the PDF for a given Dataspace::Submission. This means use ghostscript
    # to add a cover page and copy it to its new home.
    # @param [EtdTransformer::Vireo::Submission]
    def process_pdf(dataspace_submission)
      vs = @vireo_export.approved_submissions[dataspace_submission.id]
      original_pdf_full_path = vs.original_pdf_full_path
      destination_path = File.join(dataspace_submission.directory_path, vs.original_pdf)
      `gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=#{Shellwords.shellescape(destination_path)} #{cover_page_full_path} #{Shellwords.shellescape(original_pdf_full_path)}`
    end

    ##
    # Take metadata from a Vireo::Submission and feed it to a Dataspace::Submission
    # for use in generating the metadata_pu.xml file
    def generate_metadata_pu(vireo_submission, dataspace_submission)
      dataspace_submission.classyear = vireo_submission.classyear
      dataspace_submission.authorid = vireo_submission.authorid
      dataspace_submission.department = vireo_submission.department
      dataspace_submission.certificate_programs = vireo_submission.certificate_programs
      dataspace_submission.mudd_walkin = walk_in_access(vireo_submission.netid, vireo_submission.title)
      dataspace_submission.embargo_length = embargo_length(vireo_submission.netid, vireo_submission.title)
      dataspace_submission.write_metadata_pu
    end

    ##
    # Take the dublin_core.xml file as provided by vireo, augment it, and add it
    # to the DataSpace import package
    def generate_dublin_core(vireo_submission, dataspace_submission)
      dc_original = vireo_submission.dublin_core_file_path
      dataspace_submission.write_dublin_core(dc_original, walk_in_access(vireo_submission.netid, vireo_submission.title))
    end

    ##
    # Load the embargo spreadsheet into memory. We use https://github.com/pythonicrubyist/creek
    # to read data from an excel spreadsheet.
    # @return [Hash]
    def load_embargo_data
      creek = Creek::Book.new @embargo_spreadsheet, with_headers: true
      m = creek.sheets[0]
      m.simple_rows.each_with_index do |row, index|
        next if index.zero? # skip the header row

        edp = EmbargoDataPoint.new(row)
        @embargo_data[edp.netid] = [] if @embargo_data[edp.netid].nil?
        @embargo_data[edp.netid] << edp
      end
    end

    ##
    # Given a netid and a title, look up the walk in access value
    def walk_in_access(netid, title)
      load_embargo_data if @embargo_data.empty?
      @embargo_data[netid].each do |edp|
        return edp.walk_in_access if match?(title, edp.title)
      end
      'No'
    end

    ##
    # The titles contain extra data that will make them harder to match on. They need cleaning.
    # Downcase, strip whitespace and punctuation.
    def normalize_title(title)
      newtitle = title.downcase
      newtitle = newtitle.split(' - ').first.strip
      newtitle.gsub(/[^a-zA-Z\s\d]/, '')
    end

    ##
    # Given two normalized titles, is the Levenshtein distance within configured parameters?
    def match?(title1, title2)
      distance = DidYouMean::Levenshtein.distance(normalize_title(title1), normalize_title(title2))
      distance < TITLE_MATCH_THRESHOLD
    end

    ##
    # Given a netid and a title, look up the embargo length.
    # Note that students can submit more than one thesis, so we must match on
    # BOTH the netid and title.
    # This will return 0 if embargo length is N/A or empty
    def embargo_length(netid, title)
      load_embargo_data if @embargo_data.empty?
      @embargo_data[netid].each do |edp|
        return edp.years.to_i if match?(title, edp.title)
      end

      0
    end
  end
end
