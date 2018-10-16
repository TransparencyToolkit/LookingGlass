module CatalystApi
  # Get full list of annotators
  def list_annotators
    http = Curl.get("#{ENV['CATALYST_URL']}/list_annotators")
    return JSON.parse(http.body_str)
  end

  # Create a new recipe
  # Recipe should be a hash with the following keys- project, title, docs_to_process, index_name, doc_type
  def create_recipe(recipe)
    http = Curl.post("#{ENV['DOCMANAGER_URL']}/create_recipe", {:recipe => recipe})
    return http.body_str.to_i
  end

  # Create a new annotator
  # Annotator should be a hash with the following keys- annotator_class, human_readable_label, icon, fields_to_check, annotator_options
  def create_annotator(annotator, recipe_id)
    http = Curl.post("#{ENV['DOCMANAGER_URL']}/create_annotator", {:annotator => annotator, :recipe_id => recipe_id})
  end

  # Gets all the recipes in index
  def get_recipes_for_index(index_name)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_recipes_for_index", {:index_name => index_name})
    return JSON.parse(http.body_str)
  end

  # Gets all the annotators corresponding to a recipe
  def get_annotators_for_recipe(recipe_id)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_annotators_for_recipe", {:recipe_id => recipe_id})
    return JSON.parse(http.body_str)
  end

  # Runs the recipe
  def run_recipe(recipe_id)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/run_recipe", {:recipe_id => recipe_id})
  end

  # Gets all the annotators corresponding to a recipe
  # updated_recipe should be same format to recipe object from create_recipe
  def update_recipe(recipe_id, updated_recipe)
    http = Curl.post("#{ENV['DOCMANAGER_URL']}/update_recipe", {:recipe_id => recipe_id,
                                                               :updated_recipe => updated_recipe })
  end

  # Gets all the annotators corresponding to a recipe
  # updated_annotator should be in the same format as the annotator object in create_annotator
  def update_annotator(annotator_id, updated_annotator)
    http = Curl.post("#{ENV['DOCMANAGER_URL']}/update_annotator", {:annotator_id => annotator_id,
                                                                  :updated_annotator => updated_annotator})
  end

  # Deletes a recipe
  def destroy_recipe(recipe_id)
    http = Curl.post("#{ENV['DOCMANAGER_URL']}/destroy_recipe", {:recipe_id => recipe_id})
  end

  # Gets all the annotators corresponding to a recipe
  def destroy_annotator(annotator_id)
    http = Curl.post("#{ENV['DOCMANAGER_URL']}/destroy_annotator", {:annotator_id => annotator_id})
  end

  # Get count of the documents that have a date after a certain point
  def get_within_range_count(index_name, field_to_search, start_filter_range, end_filter_range, doc_type)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/run_range_query_catalyst_count", {index_name: index_name,
                                                                          start_filter_range: start_filter_range,
                                                                          end_filter_range: end_filter_range,
                                                                          field_to_search: field_to_search,
                                                                          doc_type: doc_type
                                                                         })
    return http.body_str
  end

  # Get count of the documents that match a query
  def get_matching_docs_count(index_name, field_to_search, search_query, doc_type)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/run_query_catalyst_count", {index_name: index_name,
                                                                    search_query: search_query,
                                                                    field_to_search: field_to_search,
                                                                    doc_type: doc_type
                                                                   })
    return http.body_str
  end

  # Get count of the documents of a certain type
  def get_total_doc_count_for_type(index_name, doc_type)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_total_doc_count_for_type", {index_name: index_name,
                                                                              doc_type: doc_type
                                                                             })
    return http.body_str
  end
  
end
