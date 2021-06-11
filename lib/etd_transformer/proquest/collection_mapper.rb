# frozen_string_literal: true

module EtdTransformer
  module Proquest
    class CollectionMapper
      attr_reader :department_name, :xml_file

      def initialize(department_name)
        @department_name = department_name
        @xml_file_path = xml_file_path
      end

      def xml_file_path
        File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'collection_map.xml'))
      end
    end
  end
end
