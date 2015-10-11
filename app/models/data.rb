load 'model_gen.rb'

class Data
  extend IndexMethods
  include IndexMethods
  include Elasticsearch::Persistence::Model
  include ENAnalyzer
  extend ModelGen
  include ModelGen
end
