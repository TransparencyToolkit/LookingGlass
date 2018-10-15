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

  def create_job
      render :json => { status: "success", message: "Catalyst job created" }
  end

  def facets
    list = get_docs_on_index_page(0, ENV['PROJECT_INDEX'])["aggregations"]
    render :json => list
  end

end
