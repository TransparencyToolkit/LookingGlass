load 'model_gen.rb'

class Doc
  extend IndexMethods
  include Elasticsearch::Persistence::Model
  include ENAnalyzer
  extend ModelGen

  # Load dataspec, analyzer settings and set index name
  loadDataspec
  index_name @index_name

  # Get settings and mapping
  self.settings = ENAnalyzer::analyzerSettings
  genMapping(settings)
end
