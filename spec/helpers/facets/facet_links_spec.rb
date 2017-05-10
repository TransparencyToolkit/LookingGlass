require "rails_helper"
include IndexApi
include FieldAttributeGetter
include FacetLinks
include FacetSidebar


RSpec.describe FacetLinks do
  describe "gen facet links" do
    it "should generate a link for a facet" do
      link = gen_facet_link("location", "United States", "United States")
      expect(link).to include("search?location=United+States")
    end

    it "should get a list of facet links" do
      query_index_results(params)
      load_result_docs_facets

      facet_list = get_facet_list_for_sidebar
      field_details = facet_list.select{|k,v| k == "location"}.first.to_a
      load_vars_for_facet_tree(field_details, @facets)
      facet_link = list_of_facet_links(@docs.first, "location", get_text(@docs.first, field_details[0]))

      expect(facet_link).to include("/search?location=")
    end
  end
end
