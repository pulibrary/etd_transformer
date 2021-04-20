# frozen_string_literal: true

require 'dataspace/import'
require 'dataspace/submission'

module EtdTransformer
  ##
  # A department worth of content to be imported into DataSpace
  module Dataspace
    autoload(:Import, File.join(__FILE__, 'import'))
    autoload(:Submission, File.join(__FILE__, 'submission'))
  end
end
