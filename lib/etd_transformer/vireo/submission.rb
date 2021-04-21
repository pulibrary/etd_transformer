# frozen_string_literal: true

module EtdTransformer
  module Vireo
    ##
    # A single DSpace Archive item downloaded from Vireo. It represents a
    # single thesis.
    class Submission
      attr_reader :row,
                  :student_id,
                  :student_name,
                  :primary_document,
                  :id,
                  :dataspace_submission,
                  :asset_directory

      def initialize(asset_directory:, row:)
        @asset_directory = asset_directory
        @row = row
        parse_row
      end

      ##
      # Pull data out of the Excel row and assign it to instance variables for ease of access.
      def parse_row
        @student_id = @row['Student ID']
        @student_name = @row['Student name']
        @primary_document = @row['Primary document']
        @id = @row['ID']
      end

      ##
      # Create the path to the source files
      def source_files_directory
        "#{@asset_directory}/DSpaceSimpleArchive/submission_#{@id}"
      end

      def original_pdf
        File.basename(@primary_document)
      end

      def original_pdf_exists?
        File.exist?(original_pdf_full_path)
      end

      def original_pdf_full_path
        File.join(source_files_directory, original_pdf)
      end
    end
  end
end
