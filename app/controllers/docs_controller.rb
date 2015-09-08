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
    doc_items = Array.new
    doc_sets = Array.new
    run_all do |dataspec, model|
      fieldhash = get_all_categories(dataspec)

      # Get page count and items
      pagenum, start = page_calc(params)
      docs = sort_results(start, fieldhash, dataspec, model)

      # Add to array to paginate
      docs.each do |d|
        doc_items.push(d)
      end

      doc_sets.push(docs)
    end

    pagenum, start = page_calc(params)
    @pagination = WillPaginate::Collection.create(pagenum, 30, doc_items.count) do |pager|
      pager.replace doc_items
    end

   # binding.pry
    #fieldhash = get_all_categories
    #pagenum, start = page_calc(params)
    #sort_results(start, fieldhash)

    # Get all facets and documents
    #@pagination = WillPaginate::Collection.create(pagenum, 30, Doc.count) do |pager|
    #  pager.replace @docs
    #end

    # FIGUREOUT: how to save response and paginate for more than one
    # Maybe answer is to search mult indexes in first place
    # But that might require weird handling of sorting fields and similar
    @facets = doc_sets[0].response["facets"]
    @docs = doc_sets[0].response["hits"]["hits"]
    
    #@facets = @docs.response["facets"]
    #@docs = @docs.response["hits"]["hits"]
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
    def sort_results(start, fieldhash, dataspec, model)
      if !dataspec.sort_field.empty?
        return model.search(sort: {dataspec.sort_field => "desc"}, from: start, size: 30, facets: fieldhash)
      else
        # REMOVE: Used to be @docs
        return model.search(from: start, size: 30, facets: fieldhash)
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
