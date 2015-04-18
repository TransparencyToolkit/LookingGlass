class NsadocsController < ApplicationController
  before_action :set_nsadoc, only: [:show]
  include FacetsQuery

  def index
    @nsadocs = Nsadoc.all
    fieldhash = get_all_categories(@field_info)
    results = Nsadoc.search facets: fieldhash
    @facets = results.response["facets"]
    @nsadocs = @nsadocs.response["hits"]["hits"].paginate(page: params[:page])
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
