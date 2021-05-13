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
                  :asset_directory,
                  :certificate_programs,
                  :title

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
        @approval_date = @row['Approval date']
        @thesis_type = @row['Thesis Type']
        @certificate_programs = [] << @row['Certificate Program']
        @student_email = @row['Student email']
        @title = @row['Title']
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

      ##
      # The full path to the original PDF.
      def original_pdf_full_path
        File.join(source_files_directory, original_pdf)
      end

      ##
      # The full path to the original dublin_core.xml file
      def dublin_core_file_path
        File.join(source_files_directory, 'dublin_core.xml')
      end

      def netid
        @student_email.split('@').first
      end

      ##
      # What year should this thesis be recorded under?
      # Note that embargos will be calculated from July 1 of classyear + embargo length
      def classyear
        string_date = @approval_date.split(' ').first
        parsed_date = Date.strptime(string_date, '%m/%d/%Y')
        parsed_date.year.to_s
      end

      ##
      # The same number is called a "Student ID" in some places and "authorid" in
      # other places, so make sure both terms work.
      def authorid
        @student_id
      end

      def home_department_thesis?
        return true if @thesis_type == 'Home Department Thesis'
      end

      ##
      # Get the department name from the spreadsheet row. Adjust as needed to adhere
      # to Princeton formatting rules.
      def adjusted_department_name
        dept_from_spreadsheet = @row['Department']
        dept_from_spreadsheet = dept_from_spreadsheet.split('(').first
        dept_from_spreadsheet = dept_from_spreadsheet.gsub('&', 'and')
        dept_from_spreadsheet = dept_from_spreadsheet.gsub('Engr', 'Engineering')
        dept_from_spreadsheet.strip
      end

      ##
      # If the 'Thesis Type' column in the spreadsheet reads 'Home Department Thesis',
      # then the department value is the same as the vireo export department value
      def department
        adjusted_department_name if home_department_thesis?
      end
    end
  end
end
