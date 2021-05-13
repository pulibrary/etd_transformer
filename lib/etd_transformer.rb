# frozen_string_literal: true

require 'etd_transformer/vireo/export'
require 'etd_transformer/vireo/submission'
require 'etd_transformer/dataspace/import'
require 'etd_transformer/dataspace/submission'
require 'etd_transformer/cli'
require 'etd_transformer/transformer'
require 'etd_transformer/embargo_data_point'

##
# Transform Princeton senior theses (a.k.a. ETDs -- electronic theses and dissertations).
# Take the thesis as received from Vireo and augment it so that it can be ingested for
# long term stewardship.
module EtdTransformer
  # ROOT = File.dirname __dir__
  autoload(:Vireo, File.join(__FILE__, 'vireo'))
  autoload(:Dataspace, File.join(__FILE__, 'dataspace'))
end
