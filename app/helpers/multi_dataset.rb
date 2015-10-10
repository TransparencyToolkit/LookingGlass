module MultiDataset
  include MiscProcess
  include GeneralUtils

  # Load everything
  def load_everything
    # Load dataspecs and create models
    @instance = InstanceSpec.new
    loadAllDatasets
    create_all_models

    # Load general vars (mult datasets grouped)
    get_all_facets
    get_all_field_info
    get_all_searchable_fields
    get_all_truncated_fields
    dataspecs_by_name
  end

  # Saves all dataspec values in @dataspecs
  def loadAllDatasets
    @dataspecs = Array.new

    # Load all dataspecs into array
    @instance.dataspec_paths.each do |dataspec_dir|
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

  # Get an attribute from a particular dataspec or fall back to all
  def use_all_or_some(check_field, all_field)
    if @dataspec_to_search
      return eval "@dataspec_to_search.#{check_field}"
    else
      return all_field
    end
  end

  # Gets the correct model
  def get_model(index_name)
    run_all do |dataspec, model|
      return model if dataspec.index_name == index_name
    end
  end

  # Get all index names
  def dataspecs_by_name
    @dataspecs_index_name = Hash.new
    run_all do |dataspec, model|
      @dataspecs_index_name[dataspec.index_name] = dataspec
    end
  end

  # Get the dataspec for an item
  def get_dataspec(doc)
    doc_index = doc["_index"]
    @dataspecs.each do |dataspec|
      return dataspec if doc_index == dataspec.index_name
    end
  end
  
  # Get all the facets
  def get_all_facets
    @all_facets = Hash.new
    run_all do |dataspec, model|
      facet_fields = get_all_categories(dataspec)
      @all_facets.merge!(facet_fields)
    end
  end

  # Get all field info
  def get_all_field_info
    @all_field_info = Array.new
    run_all do |dataspec, model|
      @all_field_info += dataspec.field_info
    end
  end

  # Get all truncated fields
  def get_all_truncated_fields
    @all_truncated_fields = Array.new
    run_all do |dataspec, model|
      @all_truncated_fields += dataspec.truncated_fields
    end
  end

  # Get all searchable fields
  def get_all_searchable_fields
    @all_searchable_fields = Array.new
    run_all do |dataspec, model|
      @all_searchable_fields += dataspec.searchable_fields
    end
  end

  # Create model
  def create_model(dataspec, model_name)
    doc_class = ClassGen.gen_class(model_name, dataspec)
    settings = ENAnalyzer.analyzerSettings
    mappings = doc_class.mappings.to_hash
    return doc_class
  end

  # Create all models
  def create_all_models
    @models = Array.new
    @dataspecs.each do |dataspec|
      @models.push(create_model(dataspec, gen_class_name(dataspec)))
    end
  end
end
