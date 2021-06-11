# frozen_string_literal: true

require 'csv'
require 'fileutils'
require 'shellwords'

module EtdTransformer
  ##
  # Orchestrate the transformation from ProQuestDissertation to DataSpaceSubmission
  class DissertationsTransformer
    attr_reader :input_dir, :output_dir

    ##
    # Accept an options hash as passed from Thor and configure a transformation.
    # @param [Hash] options
    def initialize(options)
      @input_dir = options[:input]
      @output_dir = options[:output]
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
