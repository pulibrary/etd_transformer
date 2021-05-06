# frozen_string_literal: true

require 'shellwords'
require 'fileutils'

module EtdTransformer
  ##
  # Orchestrate the transformation of a Vireo export into something else
  class Transformer
    attr_reader :input_dir, :output_dir, :department, :vireo_export, :dataspace_import, :embargo_spreadsheet

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
      dataspace_submission.mudd_walkin = walk_in_access(vireo_submission.netid)
      dataspace_submission.embargo_length = embargo_length(vireo_submission.netid)
      dataspace_submission.write_metadata_pu
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

        netid = row["Submitted By"].split("|").last.split("\\").last
        @embargo_data[netid] = row["Embargo Years"]
        @walk_in_data[netid] = row["Walk In Access"]
      end
    end

    ##
    # There is a column in the embargo spreadsheet called Walk in Access
    def walk_in_access(netid)
      load_embargo_data if @walk_in_data.empty?
      @walk_in_data[netid]
    end

    ##
    # Given a netid, look up the embargo length
    # This will return 0 if embargo length is N/A or empty
    def embargo_length(netid)
      load_embargo_data if @embargo_data.empty?
      @embargo_data[netid].to_i
    end
  end
end
