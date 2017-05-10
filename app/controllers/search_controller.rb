class SearchController < ApplicationController
  include ParamParsing
  include IndexApi
  include LoadResults

  def index
    # Parse params
    facets, search_query, range_query = parse_all_params
    
    # Get the index results/docs to display
    query_search_results(params, search_query, range_query, facets)

    # Save the docs and facets in vars and paginate
    load_result_docs_facets

    # Render index action (uses same as docs)
    render 'docs/index'
  end
end
