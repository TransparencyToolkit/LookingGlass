class NsadocsController < ApplicationController
  before_action :set_nsadoc, only: [:show]
  include FacetsQuery

  def index
    fieldhash = get_all_categories(@field_info)
    results = Nsadoc.search facets: fieldhash
    @facets = results.response["facets"]

    pagenum = params[:page] ? params[:page].to_i : 1
    start = pagenum*30-30
    @nsadocs = Nsadoc.search(from: start, size: 30)
    @pagination = WillPaginate::Collection.create(pagenum, 30, Nsadoc.count) do |pager|
      pager.replace @nsadocs
    end
    @nsadocs = @nsadocs.response["hits"]["hits"]
  end

  def show
    @nsadoc = ""
    @nsadocs = ""
    @link_type = Hash.new

    @field_info.each do |f|
      if f["Link"]
        @link_type["Link Field"] = f["Field Name"]
        @link_type["Link Type"] = f["Link"]
      end
    end

    if @link_type["Link Type"] == "mult_items"
      @nsadocs = Nsadoc.search(query: { match: {name: Nsadoc.find(params[:id])[@link_type["Link Field"]] }})
    else
      @nsadoc = Nsadoc.find(params[:id])
    end
    
    respond_to do |format|
      format.html
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nsadoc
        @nsadoc = Nsadoc.find(params[:id])
    end
end
