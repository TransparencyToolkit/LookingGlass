class SearchController < ApplicationController
  def index
    # Pass params to SearchQuery model (which builds query and gets results)
    s = SearchQuery.new(params, @field_info)
    @nsadocs = s.build_query
    @facets = @nsadocs.response["facets"]
  end
end
