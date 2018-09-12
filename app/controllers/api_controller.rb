class ApiController < ApplicationController
  include IndexApi

  def facets
    list = get_docs_on_index_page(0, ENV['PROJECT_INDEX'])["aggregations"]

    render :json => list
  end

end
