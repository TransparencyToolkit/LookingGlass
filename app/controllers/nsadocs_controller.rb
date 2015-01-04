class NsadocsController < ApplicationController
  before_action :set_nsadoc, only: [:show]

  def index
    @nsadocs = Nsadoc.all
    fieldList = JSON.parse(File.read("app/dataspec/nsadata.json"))
    fieldhash = Hash.new
    fieldList.each do |f|
      if f["Facet?"] == "Yes"
        fieldhash[f["Field Name"].to_sym] = {terms: {field: f["Field Name"], size: f["Size"]}}
      end
    end
 
    results = Nsadoc.search facets: fieldhash
    @facets = results.response["facets"]
  end

  def makedocview
    @docid = params[:docid]
    @docidfull = params[:docidfull]
    
    respond_to do |format|
      format.js {render layout: false}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nsadoc
      @nsadoc = Nsadoc.find(params[:id])
    end
end
