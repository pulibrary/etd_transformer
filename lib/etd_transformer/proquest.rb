# frozen_string_literal: true

require 'proquest/dissertation'
require 'proquest/collection_mapper'

module EtdTransformer
  ##
  # Code relating to files as received from Proquest
  module Proquest
    autoload(:Dissertation, File.join(__FILE__, 'dissertation'))
    autoload(:CollectionMapper, File.join(__FILE__, 'collection_mapper'))
  end
end
