module ClassGen
  def self.gen_class(class_name, dataspec)
    new_class = Class.new(Object) do
      # Set name for class
      @class_name = class_name
      def self.model_name
        ActiveModel::Name.new(self, nil, @class_name)
      end

      # Import needed methods
      require 'elasticsearch/model'
      include Elasticsearch::Persistence::Model
      include Elasticsearch::Model
      include ENAnalyzer
      extend ModelGen

      # Load dataspec
      dataspec
      index_name dataspec.index_name

      # Gen settings and mapping
      settings = ENAnalyzer::analyzerSettings
      genMapping(settings, dataspec)
    end

    # Set constant and return class
    const_set(class_name, new_class)
    return new_class
  end
end
