module MultiDataset
  include MiscProcess

  # Saves all dataspec values in @dataspecs
  def loadAllDatasets
    # Load dataspec paths
    dataspec_paths = JSON.parse(File.read("app/dataspec/importer.json"))[0]["Dataset Config"]
    @dataspecs = Array.new

    # Load all dataspecs into array
    dataspec_paths.each do |dataspec_dir|
      @dataspecs.push(DataspecContent.new(dataspec_dir))
    end
  end

  # Run block of code on all
  def run_all(&block)
    @models.each_with_index do |model, index|
      dataspec = @dataspecs[index]
      yield(dataspec, model)
    end
  end

  # Create models
  def create_model(dataspec, model_name)
    doc_class = ClassGen.gen_class(model_name, dataspec)
    settings = ENAnalyzer.analyzerSettings
    mappings = doc_class.mappings.to_hash
    return doc_class
  end

  def create_all_models
    @models = Array.new
    @dataspecs.each do |dataspec|
      @models.push(create_model(dataspec, gen_class_name(dataspec)))
    end
  end

  # Create all
  # Get list of models
  # Add to routes and get all in controller
end
