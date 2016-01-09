load 'model_gen.rb'

class Data
  include Elasticsearch::Persistence::Model
  include ENAnalyzer
  extend ModelGen
  include ModelGen
end
