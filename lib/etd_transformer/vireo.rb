# frozen_string_literal: true

require 'vireo/export'
require 'vireo/submission'
require 'vireo/incomplete_spreadsheet_error'

module EtdTransformer
  ##
  # Code relating to files as received from Vireo
  module Vireo
    autoload(:Export, File.join(__FILE__, 'export'))
    autoload(:Submission, File.join(__FILE__, 'submission'))
    autoload(:IncompleteSpreadsheetError, File.join(__FILE__, 'incomplete_spreadsheet_error'))
  end
end
