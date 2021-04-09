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
      end
    end
  end
end
