class ApiController < ApplicationController
  include CatalystApi
  include IndexApi

  # Might be good to explain Catalyst failures with something like
  #   { status: "error", message: "Cannot communicate with Catalyst server" }
  def annotators
    render :json => list_annotators
  end

  # Get the count of documents matching a recipe
  def recipe_search
    # Parse the recipe
    recipe = parse_recipe(params["recipe"])
    docs_to_process = recipe[:docs_to_process]

    # Get the count
    count = get_filtered_count(recipe, docs_to_process)
    render :json => { status: "success", message: "#{count.to_s} documents found matching query. The below text miners will only run on these #{count.to_s} documents." }
  end

  # Creates the recipe and annotators and runs the job
  def create_job
    recipe = JSON.parse(params["job"])["recipe"]
    annotators = JSON.parse(params["job"])["annotators"]
    recipe_id = prepare_recipe(recipe)
    
    # Create the annotators
    annotators.each do |annotator|
      prepare_annotator(annotator, recipe_id)
    end
    
    # Run the recipe
    run_recipe(recipe_id)
    render :json => { status: "success", message: "Catalyst job created" }
  end

  def facets
    list = get_docs_on_index_page(0, ENV['PROJECT_INDEX'])["aggregations"]
    render :json => list
  end

  private

  # Get the number of documents matching Catalyst filter query
  def get_filtered_count(recipe, docs_to_process)
    # Get the count of the filtered documents
    if docs_to_process[:run_over] == "within_range"
      return get_within_range_count(recipe[:index_name], docs_to_process[:field_to_search],
                                    docs_to_process[:filter_query], docs_to_process[:end_filter_range], recipe[:doc_type])
    elsif docs_to_process[:run_over] == "matching_query"
      return get_matching_docs_count(recipe[:index_name], docs_to_process[:field_to_search],
                                     docs_to_process[:filter_query], recipe[:doc_type])
    elsif docs_to_process[:run_over] == "all"
      return get_total_doc_count_for_type(recipe[:index_name], recipe[:doc_type])
    end
    
  end

  # Create and save the recipe and return the ID
  def prepare_recipe(job)
    # Reformat the recipe as needed
    recipe = parse_recipe(job)

    # Create the recipe
    return create_recipe(JSON.pretty_generate(recipe))
  end

  # Parse the recipe but don't create
  def parse_recipe(job)
    return {
      title: recipe_name = job["filter_name"],
      doc_type: job["default_dataspec"],
      index_name: ENV['PROJECT_INDEX'],
      docs_to_process: {
        run_over: job["run_over"],
        field_to_search: job["field_to_search"],
        filter_query: job["filter_query"],
        end_filter_range: job["end_filter_range"]
      }
    }
  end

  # Prepare and save annotator
  def prepare_annotator(a, recipe_id)
    # Parse each one into correct format, preparsing some fields
    unparsed = a.map{|v| [v["name"], v["value"]]}.to_h
    fields_to_check = unparsed["fields_to_check[]"].is_a?(Array) ? unparsed["fields_to_check[]"] : [unparsed["fields_to_check[]"]]
    annotator_options = unparsed.select{|k,v| k.include?("input_params")}.to_a.map{|i| [i[0].gsub("input_params[]", ""), i[1]]}.to_h

    # Generate annotator
    annotator = {
      human_readable_label: unparsed["filter_name"],
      icon: unparsed["filter_icon"],
      annotator_class: unparsed["annotator_name"],
      fields_to_check: fields_to_check,
      annotator_options: annotator_options
    }

    # Create the annotator
    create_annotator(JSON.pretty_generate(annotator), recipe_id)
  end

end
