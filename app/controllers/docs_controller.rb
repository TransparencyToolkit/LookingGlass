class DocsController < ApplicationController
  before_action :set_doc, only: [:show]
  include FacetsQuery
  include ControllerUtils

  def description
    
  end

  def advancedsearch
  end

  def index
    fieldhash = get_all_categories
    pagenum, start = page_calc(params)
    sort_results(start, fieldhash)

    # Get all facets and documents
    @pagination = WillPaginate::Collection.create(pagenum, 30, Doc.count) do |pager|
      pager.replace @docs
    end
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
    def sort_results(start, fieldhash)
      if !@sort_field.empty?
        @docs = Doc.search(sort: {@sort_field => "desc"}, from: start, size: 30, facets: fieldhash)
      else
        @docs = Doc.search(from: start, size: 30, facets: fieldhash)
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
