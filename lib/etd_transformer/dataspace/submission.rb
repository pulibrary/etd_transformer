# frozen_string_literal: true

require 'fileutils'

module EtdTransformer
  module Dataspace
    # A single thesis, post-processing, ready for import into DataSpace
    class Submission
      attr_reader :dataspace_import, :id
      attr_accessor :authorid, :classyear, :department, :certificate_programs, :embargo_length, :mudd_walkin

      WALKIN_MESSAGE = 'Walk-in Access. This thesis can only be viewed on computer
      terminals at the <a href=http://mudd.princeton.edu>Mudd Manuscript Library</a>.'

      def initialize(dataspace_import, id)
        @dataspace_import = dataspace_import
        @id = id
        @certificate_programs = []
        FileUtils.mkdir_p(directory_path)
      end

      def directory_path
        File.join(@dataspace_import.output_dir, "submission_#{@id}")
      end

      ##
      # Take the original dublin_core.xml file and augment it with the Mudd walkin
      # data as indicated. Write it to the expected place.
      # @param [String] original_dc_file full path to the original dublin_core.xml file
      # @param [String] mudd_walkin "Yes" or "No"
      def write_dublin_core(original_dc_file, mudd_walkin)
        doc = File.open(original_dc_file) { |f| Nokogiri::XML(f) }
        if mudd_walkin.downcase == 'yes'
          rights = Nokogiri::XML::Node.new "rights.accessRights", doc
          rights.content = WALKIN_MESSAGE
          doc.root.add_child(rights)
        end
        File.write(dublin_core_file_path, doc.to_xml)
      end

      ##
      # Given a snippet of dublin core xml, write it to the expected file
      # @param [String] An XML serialization of dublin core
      def write_dublin_core_from_xml(dublin_core_xml)
        File.write(dublin_core_file_path, dublin_core_xml)
      end

      ##
      # Given a snippet of xml, write it to the expected file
      # @param [String] An XML serialization of metadata_pu
      def write_metadata_pu_from_xml(metadata_pu_xml)
        File.write(metadata_pu_path, metadata_pu_xml)
      end

      ##
      # Given the handle of a collection, write it to a collections file
      # @param [String] The handle of a DSpace collection
      def write_collections_file(handle)
        File.write(collections_file_path, handle)
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
            if @mudd_walkin
              xml.dcvalue(element: 'mudd', qualifier: 'walkin') do
                xml.text @mudd_walkin
              end
            end
            if embargo_terms
              xml.dcvalue(element: 'embargo', qualifier: 'terms') do
                xml.text embargo_terms
              end
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

      def dublin_core_file_path
        File.join(directory_path, 'dublin_core.xml')
      end

      def collections_file_path
        File.join(directory_path, 'collections')
      end

      ##
      # The embargo release date is 1 July of the classyear plus the embargo length
      def embargo_terms
        return false unless @embargo_length&.positive?

        year = @classyear.to_i + @embargo_length
        "#{year}-07-01"
      end

      ##
      # Write a metadata_pu.xml file containing DSpace extra metadata.
      def write_metadata_pu
        File.write(metadata_pu_path, metadata_pu.to_xml)
      end
    end
  end
end
