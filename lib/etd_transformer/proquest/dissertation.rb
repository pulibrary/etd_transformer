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
            xml.dcvalue(element: 'title') do
              xml.text title
            end
            xml.dcvalue(element: 'description', qualifier: 'abstract') do
              xml.text abstract
            end
            xml.dcvalue(element: 'contributor', qualifier: 'advisor') do
              xml.text advisor
            end
            xml.dcvalue(element: 'contributor', qualifier: 'other') do
              xml.text "#{department} Department"
            end
            xml.dcvalue(element: 'date', qualifier: 'created') do
              xml.text accept_date
            end
            xml.dcvalue(element: 'date', qualifier: 'issued') do
              xml.text comp_date
            end
            xml.dcvalue(element: 'format', qualifier: 'mimetype') do
              xml.text "application/pdf"
            end
            xml.dcvalue(element: 'language', qualifier: 'iso') do
              xml.text iso_language
            end
            keywords.each do |keyword|
              xml.dcvalue(element: 'subject', qualifier: 'none') do
                xml.text keyword
              end
            end
            subjects.each do |subject|
              xml.dcvalue(element: 'subject', qualifier: 'classification') do
                xml.text subject
              end
            end
            xml.dcvalue(element: 'type') do
              xml.text "Academic dissertations (#{degree})"
            end
            xml.dcvalue(element: 'relation', qualifier: 'isformatof') do
              xml.cdata "The Mudd Manuscript Library retains one bound
              copy of each dissertation.  Search for these copies in the library's
              main catalog: <a href=http://catalog.princeton.edu>catalog.princeton.edu</a>"
            end
            xml.dcvalue(element: 'publisher') do
              xml.text "Princeton, NJ : Princeton University"
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
      # Must be in "YYYY-MM-dd" format
      def accept_date
        proquest_date = metadata.xpath('//DISS_accept_date').text
        Date.parse(proquest_date).strftime("%Y-%m-%d")
      end

      def comp_date
        metadata.xpath('//DISS_comp_date').text
      end

      ##
      # Get the title from the XML
      def title
        metadata.xpath('/DISS_submission/DISS_description/DISS_title').text
      end

      def abstract
        metadata.xpath('//DISS_abstract').text.strip
      end

      def advisor
        format_name(metadata.xpath('//DISS_advisor/DISS_name'))
      end

      ##
      # Get the author from the XML
      def author
        format_name(metadata.xpath('/DISS_submission/DISS_authorship/DISS_author/DISS_name'))
      end

      def degree
        metadata.xpath('//DISS_degree').text.strip
      end

      def iso_language
        metadata.xpath('//DISS_language').text
      end

      ##
      # Return an array of keywords
      def keywords
        words = []
        keyword_elements = metadata.xpath('//DISS_keyword')
        keyword_elements.each do |keyword_element|
          keyword_element.text.split(",").each do |k|
            words << k.strip
          end
        end
        words
      end

      ##
      # Return an array of subjects
      def subjects
        words = []
        subject_elements = metadata.xpath('//DISS_categorization/DISS_category/DISS_cat_desc')
        subject_elements.each do |subject_element|
          words << subject_element.text.strip
        end
        words
      end

      ##
      # Given a DISS_name element, format it as a string
      def format_name(diss_name_element)
        fname = diss_name_element.xpath('DISS_fname').text
        middle = diss_name_element.xpath('DISS_middle').text
        surname = diss_name_element.xpath('DISS_surname').text
        suffix = diss_name_element.xpath('DISS_suffix').text
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
