# frozen_string_literal: true

require 'byebug'
require 'thor'

module EtdTransformer
  ##
  # Command line interface for processing theses
  class Cli < Thor
    option :input, desc: 'Full path to input files', alias: 'i'
    option :output, desc: 'Full path to output', alias: 'o'
    desc 'process', 'Process vireo ETDs into DataSpace ETDs'
    def process
      if all_required_options_present?
        puts "Processing directory #{options[:input]}."
        puts "Output will be written to #{options[:output]}"
        # EtdTransformer::Vireo::Export.migrate(options[:input])
      else
        output_help_message
      end
    end

    def self.exit_on_failure?
      true
    end

    no_commands do
      def output_help_message
        puts 'Type thor help etd_transformer:cli:process for a list of all options'
      end

      def all_required_options_present?
        true if options[:input] && options[:output]
      end
    end
  end
end