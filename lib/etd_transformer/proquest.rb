# frozen_string_literal: true

require 'proquest/dissertation'

module EtdTransformer
  ##
  # Code relating to files as received from Proquest
  module Proquest
    autoload(:Dissertation, File.join(__FILE__, 'dissertation'))
  end
end
