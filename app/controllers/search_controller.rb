class SearchController < ApplicationController
  def index
    # Pass params to SearchQuery model (which builds query and gets results)
    params.delete_if { |k, v| v.empty? }
    s = SearchQuery.new(params, @field_info)
    query = s.build_query
    @nsadocs = Nsadoc.search(query)
    @facets = @nsadocs.response["facets"]
    @nsadocs = @nsadocs.response["hits"]["hits"].paginate(page: params[:page])
  end
end
