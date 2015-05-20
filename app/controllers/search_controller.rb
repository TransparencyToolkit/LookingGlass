class SearchController < ApplicationController
  def index
    # Calculate start and page num
    pagenum = params[:page] ? params[:page].to_i : 1
    start = pagenum*30-30
    
    # Pass params to SearchQuery model (which builds query and gets results)
    params.delete_if { |k, v| v.empty? }
    s = SearchQuery.new(params, @field_info, start)
    query = s.build_query
    
    @nsadocs = Nsadoc.search(query)
    @facets = @nsadocs.response["facets"]
    
    @pagination = WillPaginate::Collection.create(pagenum, 30, @nsadocs.response.hits.total) do |pager|
      pager.replace @nsadocs
    end
    @nsadocs = @nsadocs.response["hits"]["hits"]
  end
end
