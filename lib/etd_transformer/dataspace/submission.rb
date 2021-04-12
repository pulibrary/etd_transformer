# frozen_string_literal: true

require 'byebug'
require 'fileutils'

module EtdTransformer
  module Dataspace
    # A single thesis, post-processing, ready for import into DataSpace
    class Submission
      attr_reader :dataspace_import, :id

      def initialize(dataspace_import, id)
        @dataspace_import = dataspace_import
        @id = id
        FileUtils.mkdir_p(directory_path)
      end

      def directory_path
        File.join(@dataspace_import.dataspace_import_directory, "submission_#{@id}")
      end
    end
  end
end
