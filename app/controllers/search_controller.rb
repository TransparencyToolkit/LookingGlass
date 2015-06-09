class SearchController < ApplicationController
  def index
    # Calculate start and page num
    pagenum = params[:page] ? params[:page].to_i : 1
    start = pagenum*30-30
    
    # Pass params to SearchQuery model (which builds query and gets results)
    params.delete_if { |k, v| v.empty? }
    s = SearchQuery.new(params, start)
    query = s.build_query
    
    @docs = Doc.search(query)
    @facets = @docs.response["facets"]
    
    @pagination = WillPaginate::Collection.create(pagenum, 30, @docs.response.hits.total) do |pager|
      pager.replace @docs
    end
    @docs = @docs.response["hits"]["hits"]
  end
end
