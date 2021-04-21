# frozen_string_literal: true

require 'creek'
require 'fileutils'

module EtdTransformer
  module Dataspace
    # A department worth of theses ready for import to Dataspace.
    # A Dataspace::Import has a department, a directory of Dataspace::Submission
    # objects, and a metadata spreadsheet in Excel.
    class Import
      attr_reader :output_dir, :department_name

      ##
      # @param [String] output Where files will be written.
      # @param [String] department_name The name of the department.
      def initialize(output_dir, department_name)
        @output_dir = output_dir
        @department_name = department_name
        setup_filesystem
      end

      ##
      # Directory where files are written. Consists of the output_dir
      # plus department name.
      def dataspace_import_directory
        File.join(output_dir, department_name)
      end

      ##
      # Ensure the directory where the Dataspace imports will be written
      def setup_filesystem
        FileUtils.mkdir_p(dataspace_import_directory)
      end
    end
  end
end
