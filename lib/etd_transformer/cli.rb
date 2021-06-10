# frozen_string_literal: true

require 'thor'

module EtdTransformer
  ##
  # Command line interface for processing theses
  class Cli < Thor
    option :input, desc: 'Full path to input files', alias: 'i'
    option :output, desc: 'Full path to output', alias: 'o'
    option :embargo_spreadsheet, desc: 'Full path to embargo spreadsheet', alias: 'e'
    option :collection_handle, desc: 'The handle identifier of the DataSpace collection destination', alias: 'c'
    desc 'process', 'Process vireo ETDs into DataSpace ETDs'
    def process
      if all_required_options_present?
        output_options
        EtdTransformer::SeniorThesesTransformer.transform(options)
      else
        output_help_message
      end
    rescue EtdTransformer::Vireo::IncompleteSpreadsheetError => e
      puts "\n\nERROR: #{e.message}"
    end

    def self.exit_on_failure?
      true
    end

    no_commands do
      def output_help_message
        puts 'Type thor help etd_transformer:cli:process for a list of all options'
      end

      def output_options
        puts "Processing directory #{options[:input]}."
        puts "Output will be written to #{options[:output]}"
        puts "Using embargo spreadsheet #{options[:embargo_spreadsheet]}"
        puts "DataSpace import collection will be #{options[:collection_handle]}"
      end

      def all_required_options_present?
        true if options[:input] && options[:output] && options[:embargo_spreadsheet] && options[:collection_handle]
      end
    end
  end
end
