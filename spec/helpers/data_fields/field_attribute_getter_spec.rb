require "rails_helper"
include DisplayTypeSwitcher
include IndexApi
include FieldAttributeGetter
include HighlightField

RSpec.describe FieldAttributeGetter do
  describe "get inner content of field attr" do
    it "should get the icon name" do
      query_index_results({page: 1})
      load_result_docs_facets
      dataspec = get_dataspec_for_doc(@docs.first)
      field_details = dataspec["source_fields"]["location"]

      expect(icon_name(field_details)).to eq("countries")
    end

    it "should get the human readable name" do
      query_index_results({page: 1})
      load_result_docs_facets
      dataspec = get_dataspec_for_doc(@docs.first)
      field_details = dataspec["source_fields"]["location"]

      expect(human_readable_title(field_details)).to eq("Location")
    end

    it "should get the field value for the document" do
      query_index_results({page: 1})
      load_result_docs_facets
      expect(field_value(@docs.first, "name")).to be_a(String)
    end
  end
end
