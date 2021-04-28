# frozen_string_literal: true

require 'fileutils'

module EtdTransformer
  module Dataspace
    # A single thesis, post-processing, ready for import into DataSpace
    class Submission
      attr_reader :dataspace_import, :id
      attr_accessor :authorid, :classyear, :department, :certificate_programs

      def initialize(dataspace_import, id)
        @dataspace_import = dataspace_import
        @id = id
        @certificate_programs = []
        FileUtils.mkdir_p(directory_path)
      end

      def directory_path
        File.join(@dataspace_import.dataspace_import_directory, "submission_#{@id}")
      end

      ##
      # Create a metadata_pu XML document
      # @example
      #   <dublin_core encoding="utf-8" schema="pu">
      #     <dcvalue element="date" qualifier="classyear">2020</dcvalue>
      #     <dcvalue element="contributor" qualifier="authorid">961152882</dcvalue>
      #     <dcvalue element="pdf" qualifier="coverpage">SeniorThesisCoverPage</dcvalue>
      #     <dcvalue element="department">Religion</dcvalue>
      #     <dcvalue element="certificate">Urban Studies Program</dcvalue>
      #   </dublin_core>
      def metadata_pu
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.dublin_core(schema: 'pu', encoding: 'UTF-8') do
            xml.dcvalue(element: 'date', qualifier: 'classyear') do
              xml.text @classyear
            end
            xml.dcvalue(element: 'contributor', qualifier: 'authorid') do
              xml.text @authorid
            end
            xml.dcvalue(element: 'pdf', qualifier: 'coverpage') do
              xml.text 'SeniorThesisCoverPage'
            end
            xml.dcvalue(element: 'department') do
              xml.text @department
            end
            @certificate_programs.each do |cp|
              xml.dcvalue(element: 'certificate') do
                xml.text cp
              end
            end
          end
        end
        builder
      end

      def metadata_pu_path
        File.join(directory_path, 'metadata_pu.xml')
      end

      ##
      # Write a metadata_pu.xml file containing DSpace extra metadata.
      def write_metadata_pu
        File.write(metadata_pu_path, metadata_pu.to_xml)
      end
    end
  end
end
