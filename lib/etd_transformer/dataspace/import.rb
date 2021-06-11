# frozen_string_literal: true

require 'creek'
require 'fileutils'

module EtdTransformer
  module Dataspace
    # A set of theses ready for import to Dataspace.
    # A Dataspace::Import has a directory of Dataspace::Submission objects.
    class Import
      attr_reader :output_dir

      ##
      # @param [String] output Where files will be written.
      def initialize(output_dir)
        @output_dir = output_dir
        setup_filesystem
      end

      ##
      # Ensure the directory where the Dataspace imports will be written
      def setup_filesystem
        FileUtils.mkdir_p(@output_dir)
      end
    end
  end
end
