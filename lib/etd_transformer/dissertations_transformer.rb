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
    end
  end
end
