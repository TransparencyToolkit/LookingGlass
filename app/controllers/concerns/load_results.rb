module LoadResults
  # Queries DocManager and loads all the docs on an index page
  def query_index_results(params)
    @pagenum, @start = page_calc(params)
    @docs = get_docs_on_index_page(@start, ENV['PROJECT_INDEX'])
    @total_count = get_total_docs(ENV['PROJECT_INDEX'])
  end

  # Query search results
  def query_search_results(params, search_query, range_query, facets)
    @pagenum, @start = page_calc(params)
    @docs = run_query(ENV['PROJECT_INDEX'], search_query, range_query, @start, facets)
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

  # Replace docs returned with manually chosen if it is first index page&there is list of documents
  def add_manually_curated_results(params)
    @project = get_project_spec(ENV["PROJECT_INDEX"])
    if should_show_manually_curated_front_page?(params)
      @front_page_docs = @project["front_page_documents"].map{|doc| get_doc(ENV["PROJECT_INDEX"], doc)}
      @docs["hits"]["hits"][0..@front_page_docs.length-1] = @front_page_docs
    end
  end

  # Check if a manual front page should be displayed
  def should_show_manually_curated_front_page?(params)
    return (@project["front_page_documents"] && params["action"] == "index" && (params["page"] == nil || params["page"] == "1"))
  end
end
