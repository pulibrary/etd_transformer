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
        check_row_for_required_fields
        parse_row
      end

      ##
      # Pull data out of the Excel row and assign it to instance variables for ease of access.
      def parse_row
        @student_id = @row['Student ID']
        @student_name = @row['Student name']
        @primary_document = @row['Primary document']
        @id = @row['ID'].to_i.to_s
        @approval_date = @row['Approval date']
        @thesis_type = @row['Thesis Type']
        @certificate_programs = [] << @row['Certificate Program']
        @student_email = @row['Student email']
        @title = @row['Title']
      end

      def check_row_for_required_fields
        missing_fields = []
        REQUIRED_FIELDS.each do |required_field_name|
          missing_fields << required_field_name if missing?(@row[required_field_name])
        end
        return if missing_fields.empty?

        message = "Student ID #{@row['Student ID']} is missing required fields: #{missing_fields}"
        raise EtdTransformer::Vireo::IncompleteSpreadsheetError, message
      end

      ##
      # Decide whether a field in the spreadsheet is missing. It is missing if it is
      # nil, or if it is a string consisting only of whitespace.
      def missing?(field)
        return true if field.nil?
        return true if field.class == Float && field.zero?
        return false if field.class == Float && field.positive?
        return true if field&.strip&.empty?

        false
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
      # The full path to the contents file
      def contents_file
        File.join(source_files_directory, 'contents')
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
        explicit_department_mapper = {
          "Architecture" => "Architecture School",
          "Independent Study" => "Independent Concentration",
          "Ops Research & Financial Engr" => "Operations Research and Financial Engineering",
          "Public & International Affairs" => "Princeton School of Public and International Affairs"
        }
        return explicit_department_mapper[@row['Department']] if explicit_department_mapper.key? @row['Department']

        dept_from_spreadsheet = @row['Department']
        dept_from_spreadsheet = dept_from_spreadsheet.split('(').first.gsub('&', 'and')
        dept_from_spreadsheet.gsub('Engr', 'Engineering').strip
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
