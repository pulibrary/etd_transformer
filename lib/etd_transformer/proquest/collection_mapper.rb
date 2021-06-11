# frozen_string_literal: true

module EtdTransformer
  module Proquest
    ##
    # Generate the proquest department -> dataspace handle mapper from XML
    class CollectionMapper
      attr_reader :department_name, :xml_file, :mapper

      def initialize
        @xml_file_path = xml_file_path
        @mapper = generate_collection_mapper
      end

      def xml_file_path
        File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'assets', 'collection_map.xml'))
      end

      def generate_collection_mapper
        mapper = {}
        doc = File.open(xml_file_path) { |f| Nokogiri::XML(f) }

        doc.xpath('.//collection').each do |el|
          department = el.xpath('name').text
          handle = el.xpath('identifier').text
          mapper[department] = handle
        end

        mapper
      end
    end
  end
end
