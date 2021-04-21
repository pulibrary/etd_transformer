# frozen_string_literal: true

module EtdTransformer
  ##
  # Orchestrate the transformation of a Vireo export into something else
  class Transformer
    attr_reader :input, :output, :department, :vireo_export

    ##
    # Convenience method for kicking off a transformation.
    # @param [Hash] options
    # @return [EtdTransformer::Transformer]
    # @example
    #  EtdTransformer::Transformer.transform(input: '/foo', output: '/bar')
    def self.transform(options)
      transformer = EtdTransformer::Transformer.new(options)
      transformer
    end

    ##
    # Accept an options hash as passed from Thor and configure a transformation.
    # @param [Hash] options
    def initialize(options)
      @input = options[:input]
      @output = options[:output]
      @department = @input.split('/').last
      @vireo_export = EtdTransformer::Vireo::Export.new(@input)
    end
  end
end
