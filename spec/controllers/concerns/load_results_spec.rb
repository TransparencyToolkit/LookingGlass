require "rails_helper"
include LoadResults
include IndexApi

RSpec.describe LoadResults do
  describe "load the results" do
    it "should load in the docs for the first page" do
      query_index_results({page: 1})
      expect(@docs["hits"]["hits"].length).to eq(30)
      expect(@pagenum).to eq(1)
      expect(@start).to eq(0)
    end

    it "should paginate the results" do
      query_index_results({page: 1})
      paginate_results
      expect(@pagination.class.to_s).to eq("WillPaginate::Collection")
      expect(@pagination.length).to eq(30)
    end

    it "should load the resulting docs and facets" do
      query_index_results({page: 1})
      load_result_docs_facets
      expect(@facets).to be_a(Hash)
      expect(@docs.length).to eq(30)
    end
  end
end
