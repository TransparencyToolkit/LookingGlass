class DocsController < ApplicationController
  before_action :set_doc, only: [:show]
  include ParamParsing
  include IndexApi
  include LoadResults

  def index
    # Get the index results/docs to display
    query_index_results(params)

    # Save the docs and facets in vars and paginate
    load_result_docs_facets
  end
end
