class SearchController < ApplicationController
  include ParamParsing
  include IndexApi
  include LoadResults

  def index
    # Parse params MOVE TO SEPARATE FUNC
    facets = parse_facet_params
    
    # Get the index results/docs to display
    query_search_results(params, facets)

    # Save the docs and facets in vars and paginate
    load_result_docs_facets
  end
end
