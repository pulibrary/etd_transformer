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
    desc 'process_theses', 'Process vireo ETDs into DataSpace ETDs'
    def process_theses
      if all_required_thesis_options_present?
        puts "Processing senior theses"
        output_options
        EtdTransformer::SeniorThesesTransformer.transform(options)
      else
        output_help_message
      end
    rescue EtdTransformer::Vireo::IncompleteSpreadsheetError => e
      puts "\n\nERROR: #{e.message}"
    end

    option :spreadsheet, desc: 'Full path to spreadsheet with multiauthor metadata', alias: 's'
    option :directory, desc: 'Full path to already processed senior theses', alias: 'd'
    desc 'multi_author', 'Add additional author metadata to processed DataSpace ETDs'
    def multi_author
      if all_required_multi_author_options_present?
        puts "Using spreadsheet #{options[:spreadsheet]}."
        puts "Adding additional author metadata to #{options[:directory]}"
        EtdTransformer::MultiAuthorAugmentor.add_metadata(options)
      else
        output_help_message
      end
    rescue EtdTransformer::Vireo::IncompleteSpreadsheetError => e
      puts "\n\nERROR: #{e.message}"
    end

    option :input, desc: 'Full path to input files', alias: 'i'
    option :output, desc: 'Full path to output', alias: 'o'
    desc 'process_dissertations', 'Process proquest ETDs into DataSpace ETDs'
    def process_dissertations
      if all_required_dissertation_options_present?
        puts "Processing dissertations"
        output_options
        EtdTransformer::DissertationsTransformer.transform(options)
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
        puts 'Type thor help etd_transformer:cli:process_theses or etd_transformer:cli:process_dissertations for a list of all options'
      end

      def output_options
        puts "Processing directory #{options[:input]}."
        puts "Output will be written to #{options[:output]}"
        puts "Using embargo spreadsheet #{options[:embargo_spreadsheet]}" if options[:embargo_spreadsheet]
        puts "DataSpace import collection will be #{options[:collection_handle]}" if options[:collection_handle]
      end

      def all_required_multi_author_options_present?
        true if options[:spreadsheet] && options[:directory]
      end

      def all_required_thesis_options_present?
        true if options[:input] && options[:output] && options[:embargo_spreadsheet] && options[:collection_handle]
      end

      def all_required_dissertation_options_present?
        true if options[:input] && options[:output]
      end
    end
  end
end
