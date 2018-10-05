class ApiController < ApplicationController
  include CatalystApi
  include IndexApi

  def annotators
    render :json => list_annotators
  end

  def facets
    list = get_docs_on_index_page(0, ENV['PROJECT_INDEX'])["aggregations"]
    render :json => list
  end

end
