# frozen_string_literal: true

require 'byebug'
require 'creek'
require 'fileutils'

module EtdTransformer
  module Dataspace
    # A department worth of theses ready for import to Dataspace.
    # A Dataspace::Import has a department, a directory of Dataspace::Submission
    # objects, and a metadata spreadsheet in Excel.
    class Import
      attr_reader :department_name

      ##
      # @param [String] department_name The name of the department.
      def initialize(department_name)
        @department_name = department_name
        setup_filesystem
      end

      ##
      # Directory where files are written. Consists of the DATASPACE_IMPORT_BASE
      # plus department name.
      def dataspace_import_directory
        raise 'Error: DATASPACE_IMPORT_BASE is nil' unless ENV['DATASPACE_IMPORT_BASE']

        File.join(ENV['DATASPACE_IMPORT_BASE'], department_name)
      end

      ##
      # Ensure the directory where the Dataspace imports will be written
      def setup_filesystem
        FileUtils.mkdir_p(dataspace_import_directory)
      end
    end
  end
end
