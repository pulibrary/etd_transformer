# frozen_string_literal: true

require 'byebug'
require 'creek'
require 'fileutils'

module EtdTransformer
  module Vireo
    # Senior theses as downloaded from Vireo, one department at a time. A Vireo::Export
    # contains a department, a zipfile, and a metadata spreadsheet in Excel.
    class Export
      attr_reader :department_name

      ##
      # @param [String] department_name The name of the department. Must match directory name.
      def initialize(department_name)
        @department_name = department_name
        load_metadata
      end

      ##
      # Migrate the contents of a Vireo export directory (which will contain the
      # theses of a single department). This will include:
      # 1. Adding a cover page to the PDF
      # 2. Adding secondary authors
      # 3. Augmenting metadata with secondary academic programs
      def migrate
        approved_dir = "#{dataspace_import_directory}/#{@department_name}/Approved"
        FileUtils.mkdir_p approved_dir
        @metadata.simple_rows.each_with_index do |row, index|
          next if index.zero? # skip the header row
          next unless row['Status'] == 'Approved'

          FileUtils.mkdir_p "#{approved_dir}/submission_#{row['ID']}"
        end
      end

      def unzip_archive
        zip_file = File.join(vireo_export_directory, @department_name, 'DSpaceSimpleArchive.zip')
        system("cd #{asset_directory}; unzip #{zip_file}")
      end

      # Directory where the vireo exports are stored
      def vireo_export_directory
        ENV['VIREO_EXPORT_DIRECTORY']
      end

      # Directory where the assets for this VireoExport are stored
      def asset_directory
        "#{vireo_export_directory}/#{@department_name}"
      end

      # Directory where the transformed theses are written
      def dataspace_import_directory
        ENV['DATASPACE_IMPORT_DIRECTORY']
      end

      # The metadata as received from Vireo
      # @return [Creek::Sheet]
      def metadata
        @metadata ||= load_metadata
      end

      def metadata_file
        "#{asset_directory}/ExcelExport.xlsx"
      end

      ##
      # Load the Excel spreadsheet into memory. We use https://github.com/pythonicrubyist/creek
      # to read data from the excel spreadsheet.
      # @return [Creek::Sheet]
      def load_metadata
        creek = Creek::Book.new metadata_file, with_headers: true
        m = creek.sheets[0]
        @metadata = m
        m
      end
    end
  end
end
