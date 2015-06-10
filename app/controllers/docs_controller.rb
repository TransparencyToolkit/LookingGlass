class DocsController < ApplicationController
  before_action :set_doc, only: [:show]
  include FacetsQuery

  def index
    fieldhash = get_all_categories

    pagenum = params[:page] ? params[:page].to_i : 1
    start = pagenum*30-30
    @docs = Doc.search(from: start, size: 30, facets: fieldhash)
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

    @field_info.each do |f|
      if f["Link"]
        @link_type["Link Field"] = f["Field Name"]
        @link_type["Link Type"] = f["Link"]
      end
    end

    # Match items by link field
    if @link_type["Link Type"] == "mult_items"
      @docs = Doc.search(query: { match: {@link_type["Link Field"].to_sym => Doc.find(params[:id])[@link_type["Link Field"]] }}, size: 999999)
    else
      @doc = Doc.find(params[:id])
    end
    
    respond_to do |format|
      format.html
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_doc
        @doc = Doc.find(params[:id])
    end
end
