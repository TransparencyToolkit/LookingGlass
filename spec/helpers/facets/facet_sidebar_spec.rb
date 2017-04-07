require "rails_helper"
include IndexApi
include FieldAttributeGetter

RSpec.describe FacetSidebar do
  describe "get content for facet" do
    it "should get a list of facets from query" do
      facet_list = get_facet_list_for_sidebar
      expect(facet_list).to be_a(Hash)
      expect(facet_list.first[1]["display_type"]).to eq("Category")
    end

    it "should load in vars for the facets" do
      query_index_results(params)
      load_result_docs_facets

      facet_list = get_facet_list_for_sidebar
      field_details = facet_list.select{|k,v| k == "location"}.first.to_a
      load_vars_for_facet_tree(field_details, @facets)

      expect(@bucket_count).to eq(500.to_s)
      expect(@aggregation.keys).to eq(["doc_count_error_upper_bound", "sum_other_doc_count", "buckets"])
    end
  end
end
