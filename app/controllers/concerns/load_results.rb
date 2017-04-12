module LoadResults
  # Queries DocManager and loads all the docs on an index page
  def query_index_results(params)
    @pagenum, @start = page_calc(params)
    @docs = get_docs_on_index_page(@start, ENV['PROJECT_INDEX'])
    @total_count = get_total_docs(ENV['PROJECT_INDEX'])
  end

  # Query search results
  def query_search_results(params, facets)
    @pagenum, @start = page_calc(params)
    @docs = run_query(ENV['PROJECT_INDEX'], params[:q], "_all", @start, facets)
    @total_count = @docs["hits"]["total"]
  end

  # Paginates the documents
  def paginate_results
    @pagination = WillPaginate::Collection.create(@pagenum, 30, @total_count) do |pager|
      pager.replace @docs["hits"]["hits"]
    end
  end

  # Load the docs and facets in the results and paginate
  def load_result_docs_facets
    paginate_results
    @facets = @docs["aggregations"]
    @docs = @docs["hits"]["hits"]
  end
end
