# coding: utf-8
class SearchController < ApplicationController
  include ControllerUtils
  
  def index
    # Calculate start and page num
    pagenum, start = page_calc(params)
    
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
