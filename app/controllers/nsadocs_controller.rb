class NsadocsController < ApplicationController
  before_action :set_nsadoc, only: [:show]

  def index
    @nsadocs = Nsadoc.all
    fieldList= JSON.parse(File.read("app/dataspec/nsadata.json"))
    fieldhash = Array.new
    fieldList.each do |f|
      if f["Searchable?"] == "Yes"
        fieldhash << f["Field Name"].to_sym} => {:terms => {:field => {f["Field Name"]}, :size => {f["Size"]}}}
      end
    end
    binding.pry
    results = Nsadoc.search fieldhash
    #facets: {
     # programs: {terms: {field: "programs", size: 1000}},
      #codewords: {terms: {field: "codewords", size: 1000}},
      #type: {terms: {field: "type", size: 1000}},
      #records_collected: {terms: {field: "records_collected", size: 1000}},
      #legal_authority: {terms: {field: "legal_authority", size: 1000}},
      #countries: {terms: {field: "countries", size: 1000}},
      #sigads: {terms: {field: "sigads", size: 1000}},
      #released_by: {terms: {field: "released_by", size: 1000}}
    #}
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def nsadoc_params
      params.require(:nsadoc).permit(:release_date, :released_by, :article_url, :title, :doc_path, :type, :legal_authority, :records_collected, :creation_date, :doc_text, :aclu_desc, :sigads, :codewords, :programs, :countries)
    end
end
