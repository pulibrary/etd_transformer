# frozen_string_literal: true

require 'byebug'
require 'creek'
require 'fileutils'
require 'etd_transformer'

module EtdTransformer
  module Vireo
    # Senior theses as downloaded from Vireo, one department at a time. A Vireo::Export
    # contains a department, a zipfile, and a metadata spreadsheet in Excel.
    class Export
      attr_reader :department_name, :asset_directory

      ##
      # @param [String] Full path to the input directory. Last directory must be a department name.
      def initialize(input)
        @asset_directory = input
        @department_name = input.split('/').last
        load_metadata
      end

      def unzip_archive
        zip_file = File.join(@asset_directory, 'DSpaceSimpleArchive.zip')
        system("cd #{@asset_directory}; unzip #{zip_file}")
      end

      # The metadata as received from Vireo
      # @return [Creek::Sheet]
      def metadata
        @metadata ||= load_metadata
      end

      def metadata_file
        "#{@asset_directory}/ExcelExport.xlsx"
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
