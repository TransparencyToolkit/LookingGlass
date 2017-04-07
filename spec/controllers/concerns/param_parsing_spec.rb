require "rails_helper"
include ParamParsing

RSpec.describe ParamParsing do
  describe "parse params" do
    it "should calculate the page number and start offset" do
      input_params1 = {page: 1}
      page1, start1 = page_calc(input_params1)
      expect(page1).to eq(1)
      expect(start1).to eq(0)

      input_params2 = {page: 2}
      page2, start2 = page_calc(input_params2)
      expect(page2).to eq(2)
      expect(start2).to eq(30)
    end
  end
end
