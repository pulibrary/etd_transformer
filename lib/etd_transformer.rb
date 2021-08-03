# frozen_string_literal: true

require 'etd_transformer/vireo/export'
require 'etd_transformer/vireo/submission'
require 'etd_transformer/vireo/incomplete_spreadsheet_error'
require 'etd_transformer/dataspace/import'
require 'etd_transformer/dataspace/submission'
require 'etd_transformer/cli'
require 'etd_transformer/senior_theses_transformer'
require 'etd_transformer/multi_author_augmentor'
require 'etd_transformer/dissertations_transformer'
require 'etd_transformer/embargo_data_point'
require 'etd_transformer/proquest/dissertation'
require 'etd_transformer/proquest/collection_mapper'

##
# Transform Princeton senior theses (a.k.a. ETDs -- electronic theses and dissertations).
# Take the ETD as received from an external system (e.g., Vireo or Proquest) and
# augment it so that it can be ingested for long term stewardship.
module EtdTransformer
  # ROOT = File.dirname __dir__
  autoload(:Vireo, File.join(__FILE__, 'vireo'))
  autoload(:Dataspace, File.join(__FILE__, 'dataspace'))
  autoload(:Proquest, File.join(__FILE__, 'proquest'))
end
