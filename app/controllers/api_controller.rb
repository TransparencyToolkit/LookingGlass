class ApiController < ApplicationController
  include CatalystApi
  include IndexApi

  # Might be good to explain Catalyst failures with something like
  #   { status: "error", message: "Cannot communicate with Catalyst server" }
  def annotators
    render :json => list_annotators
  end

  def recipe_search
    render :json => { status: "success", message: "Some stuff here" }
  end

  # Creates the recipe and annotators and runs the job
  def create_job
    job = JSON.parse(params["job"])
    recipe_id = prepare_recipe(job)

    # Create the annotators
    job["annotators"].each do |annotator|
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

  # Create and save the recipe and return the ID
  def prepare_recipe(job)
    # Reformat the recipe as needed
    recipe = {
      title: recipe_name = job["recipe"]["filter_name"],
      doc_type: job["recipe"]["default_dataspec"],
      index_name: ENV['PROJECT_INDEX'],
      docs_to_process: {
        run_over: job["recipe"]["run_over"]
      }
    }
    return create_recipe(JSON.pretty_generate(recipe))
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
