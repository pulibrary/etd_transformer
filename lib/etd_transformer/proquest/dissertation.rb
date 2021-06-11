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
      # Parse the metadata xml
      def metadata
        @metadata ||= File.open(metadata_xml) { |f| Nokogiri::XML(f) }
      end

      ##
      # Unzip the zipfile
      def extract_zip
        FileUtils.mkdir_p(dir)

        Zip::File.open(@zipfile) do |zip_file|
          zip_file.each do |f|
            fpath = File.join(dir, f.name)
            FileUtils.mkdir_p(File.dirname(fpath))
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
      end
    end
  end
end
