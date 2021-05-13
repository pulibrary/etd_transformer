# frozen_string_literal: true

module EtdTransformer
  ##
  # Given a row from an embargo spreadsheet, make an object we can use to calculate embargo
  class EmbargoDataPoint
    attr_reader :netid, :title, :walk_in_access, :years

    ##
    # @param [Hash] spreadsheet_row - a single row from the embargo spreadsheet
    def initialize(spreadsheet_row)
      @netid = spreadsheet_row["Submitted By"].split("|").last.split("\\").last
      @title = spreadsheet_row["Name"]
      @walk_in_access = spreadsheet_row["Walk In Access"]
      @years = spreadsheet_row["Embargo Years"]
    end
  end
end
