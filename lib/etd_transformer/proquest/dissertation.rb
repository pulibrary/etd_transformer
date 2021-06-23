# frozen_string_literal: true

module EtdTransformer
  module Proquest
    ##
    # A single Proquest dissertation
    class Dissertation
      attr_reader :zipfile

      def initialize(zipfile)
        @zipfile = zipfile
        extract_zip
      end

      ##
      # Produce an XML dublin core record suitable for ingest into DSpace
      def dublin_core
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.dublin_core(schema: 'dc', encoding: 'UTF-8') do
            xml.dcvalue(element: 'contributor', qualifier: 'author') do
              xml.text author
            end
          end
        end
        builder
      end

      ##
      # Use the id from the zipfile
      def id
        File.basename(@zipfile).split("_").last.split(".zip").first
      end

      ##
      # Full path to the metadata xml file
      def metadata_xml
        Dir["#{dir}/*DATA.xml"].first
      end

      ##
      # Full path location of the files for this ProQuest dissertation
      def dir
        @dir ||= @zipfile.gsub('.zip', '')
      end

      ##
      # Get the title from the XML
      def title
        metadata.xpath('/DISS_submission/DISS_description/DISS_title').text
      end

      ##
      # Get the author from the XML
      def author
        fname = metadata.xpath('/DISS_submission/DISS_authorship/DISS_author/DISS_name/DISS_fname').text
        middle = metadata.xpath('/DISS_submission/DISS_authorship/DISS_author/DISS_name/DISS_middle').text
        surname = metadata.xpath('/DISS_submission/DISS_authorship/DISS_author/DISS_name/DISS_surname').text
        suffix = metadata.xpath('/DISS_submission/DISS_authorship/DISS_author/DISS_name/DISS_suffix').text
        names = [fname, middle, surname, suffix]
        no_empty_names = names.reject(&:empty?)
        no_empty_names.join(' ').squeeze(" ").strip
      end

      ##
      # Get the department from the XML
      def department
        metadata.xpath('//DISS_submission//DISS_institution//DISS_inst_contact').text
      end

      ##
      # Get the embargo date from the XML
      def embargo_date
        restriction_a = metadata.xpath('*//DISS_sales_restriction')
        return if restriction_a.empty?

        mm_dd_yyyy_embargo = restriction_a[0].attributes["remove"].value
        Date.strptime(mm_dd_yyyy_embargo, '%m/%d/%Y').to_s
      end

      ##
      # Parse the metadata xml
      def metadata
        @metadata ||= File.open(metadata_xml) { |f| Nokogiri::XML(f) }
      end

      ##
      # Map the department to the handle
      def handle
        mapper = EtdTransformer::Proquest::CollectionMapper.new.mapper
        mapper[department]
      end

      ##
      # Unzip the zipfile
      def extract_zip
        FileUtils.mkdir_p(dir)

        Zip::File.open(@zipfile) do |zip_file|
          zip_file.each do |file|
            fpath = File.join(dir, file.name)
            FileUtils.mkdir_p(File.dirname(fpath))
            zip_file.extract(file, fpath) unless File.exist?(fpath)
          end
        end
      end
    end
  end
end
