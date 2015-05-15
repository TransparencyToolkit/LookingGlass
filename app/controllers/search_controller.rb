class SearchController < ApplicationController
  def index
    # Pass params to SearchQuery model (which builds query and gets results)
    params.delete_if { |k, v| v.empty? }
    s = SearchQuery.new(params, @field_info)
    query = s.build_query
    
    pagenum = params[:page].to_i ? params[:page].to_i : 1
    start = pagenum*30-30
    @nsadocs = Nsadoc.search(query, from: start, size: 30)
    @facets = @nsadocs.response["facets"]
    
    @pagination = WillPaginate::Collection.create(pagenum, 30, @nsadocs.response.hits.total) do |pager|
      pager.replace @nsadocs
    end
    @nsadocs = @nsadocs.response["hits"]["hits"]
  end
end
