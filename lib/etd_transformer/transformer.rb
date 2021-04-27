# frozen_string_literal: true

module EtdTransformer
  ##
  # Orchestrate the transformation of a Vireo export into something else
  class Transformer
    attr_reader :input_dir, :output_dir, :department, :vireo_export, :dataspace_import

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
      @department = @input_dir.split('/').last
      @vireo_export = EtdTransformer::Vireo::Export.new(@input_dir)
      @dataspace_import = EtdTransformer::Dataspace::Import.new(@output_dir, @department)
    end

    ##
    # Orchestrate the transformation of a Vireo::Export
    def transform
      dataspace_submissions.each do |ds|
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
      `cp #{original_license} #{destination_path}`
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
      `gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=#{destination_path} #{cover_page_full_path} #{original_pdf_full_path}`
    end
  end
end
