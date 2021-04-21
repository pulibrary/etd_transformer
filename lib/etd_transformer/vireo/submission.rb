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
                  :dataspace_submission

      def initialize(vireo_export:, row:)
        @vireo_export = vireo_export
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
        "#{@vireo_export.asset_directory}/DSpaceSimpleArchive/submission_#{@id}"
      end

      def original_pdf
        File.basename(@primary_document)
      end

      def original_pdf_exists?
        full_path = File.join(source_files_directory, original_pdf)
        File.exist?(full_path)
      end

      def asset_directory
        @vireo_export.asset_directory
      end
    end
  end
end
