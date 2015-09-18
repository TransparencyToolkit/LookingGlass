load 'model_gen.rb'

class Data
  extend IndexMethods
  include IndexMethods
  include Elasticsearch::Persistence::Model
  include ENAnalyzer
  extend ModelGen
  include ModelGen

  # Load dataspec, analyzer settings and set index name
  #loadDataspec
  #index_name @index_name

  # Get settings and mapping
  #self.settings = ENAnalyzer::analyzerSettings
  #genMapping(settings)
end