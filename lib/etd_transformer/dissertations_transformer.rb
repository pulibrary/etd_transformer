# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'shellwords'

module EtdTransformer
  ##
  # Orchestrate the transformation from ProQuestDissertation to DataSpaceSubmission
  class DissertationsTransformer
    attr_reader :input_dir, :output_dir, :dataspace_import

    def self.transform(options)
      dt = EtdTransformer::DissertationsTransformer.new(options)
      dt.dissertations.each do |dissertation|
        dataspace_submission = EtdTransformer::Dataspace::Submission.new(dt.dataspace_import, dissertation.id)
        dt.transform(dissertation, dataspace_submission)
        puts dissertation.title
      end
    end

    ##
    # Transform a given ProQuestDissertation into a specific DataSpaceSubmission
    def transform(proquest_dissertation, dataspace_submission)
      dataspace_submission.write_dublin_core_from_xml(proquest_dissertation.dublin_core.to_xml)
    end

    ##
    # Accept an options hash as passed from Thor and configure a transformation.
    # @param [Hash] options
    def initialize(options)
      @input_dir = options[:input]
      @output_dir = options[:output]
      @dataspace_import = EtdTransformer::Dataspace::Import.new(@output_dir)
      setup_filesystem
      create_dissertations
    end

    ##
    # Ensure the directory where the Dataspace imports will be written exists
    def setup_filesystem
      FileUtils.mkdir_p(@output_dir)
    end

    def dissertations
      @dissertations ||= create_dissertations
    end

    def create_dissertations
      @dissertations = []
      Dir["#{@input_dir}/*.zip"].each do |dissertation_zipfile|
        pd = EtdTransformer::Proquest::Dissertation.new(dissertation_zipfile)
        dissertations << pd
      end
    end
  end
end
