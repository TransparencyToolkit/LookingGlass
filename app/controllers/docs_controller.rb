class DocsController < ApplicationController
  before_action :set_doc, only: [:show]
  include FacetsQuery
  include ControllerUtils
  include MultiDataset

  def description
    
  end

  def advancedsearch
  end

  def index
    # Get a list of all facets
    get_all_facets
    
    # Get docs, pages, and count
    pagenum, start = page_calc(params)
    docs = sort_results(start, @all_facets, @dataspecs.first)
    @total_count = get_total_docs 

    # Paginate documents
    @pagination = WillPaginate::Collection.create(pagenum, 30, @total_count) do |pager|
      pager.replace @docs
    end
  
    # Get facets and documents
    @facets = @docs.response["facets"]
    @docs = @docs.response["hits"]["hits"]
  end

  def show
    @doc = ""
    @docs = ""
    @link_type = Hash.new

    set_link_field
    get_matching_set
    
    respond_to do |format|
      format.html
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_doc
        @doc = Doc.find(params[:id])
    end

    # Sorts the results
    def sort_results(start, all_facet_fields, dataspec)
      if !dataspec.sort_field.empty?
        @docs = Elasticsearch::Model.search({sort: {dataspec.sort_field => "desc"}, from: start, size: 30, facets: all_facet_fields}, @models) #NOTE: sort is broken
      else
        @docs = Elasticsearch::Model.search({from: start, size: 30, facets: all_facet_fields}, @models)
      end
    end

    # Set field that links items
    def set_link_field
      @field_info.each do |f|
        if f["Link"]
          @link_type["Link Field"] = f["Field Name"]
          @link_type["Link Type"] = f["Link"]
        end
      end
    end

    # Get all items with matching link field
    def get_matching_set
      if @link_type["Link Type"] == "mult_items"
        @docs = Doc.search(query: { match: {@link_type["Link Field"].to_sym => Doc.find(params[:id])[@link_type["Link Field"]] }}, size: 999999)
      else
        @doc = Doc.find(params[:id])
      end
    end
end
