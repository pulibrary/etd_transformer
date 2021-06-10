# frozen_string_literal: true

module EtdTransformer
  module Proquest
    ##
    # A single Proquest dissertation
    class Dissertation
      attr_reader :zipfile, :dir

      def initialize(zipfile)
        @zipfile = zipfile
      end

      ##
      # Unzip the zipfile
      def extract_zip
        @dir = @zipfile.gsub('.zip', '')
        FileUtils.mkdir_p(@dir)

        Zip::File.open(@zipfile) do |zip_file|
          zip_file.each do |f|
            fpath = File.join(@dir, f.name)
            FileUtils.mkdir_p(File.dirname(fpath))
            zip_file.extract(f, fpath) unless File.exist?(fpath)
          end
        end
      end
    end
  end
end
