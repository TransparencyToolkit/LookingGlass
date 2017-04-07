require "rails_helper"
include DisplayTypeSwitcher
include IndexApi
include FieldAttributeGetter
include HighlightField

RSpec.describe DisplayTypeSwitcher do
  describe "switch between display types" do
    it "should print fields for the doc" do
      query_index_results({page: 1})
      load_result_docs_facets
      dataspec = get_dataspec_for_doc(@docs.first)
      title_link = show_by_type("Title", @docs.first, dataspec)
      expect(title_link).to include("a class")
      expect(title_link).to include("_blank")
    end

    it "should switch between types" do
      query_index_results({page: 1})
      load_result_docs_facets
      dataspec = get_dataspec_for_doc(@docs.first)

      field_details = dataspec["source_fields"]["screen_name"]
      field = "screen_name"
      type = "Title"
      output = type_switcher(type, @docs.first, field, field_details)

      expect(output).to include("a class")
      expect(output).to include("_blank")
    end
  end
end
