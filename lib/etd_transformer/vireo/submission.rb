# frozen_string_literal: true

module EtdTransformer
  module Vireo
    ##
    # A single DSpace Archive item downloaded from Vireo. It represents a
    # single thesis.
    class Submission
      attr_reader :row

      def initialize(row)
        @row = row
      end
    end
  end
end
