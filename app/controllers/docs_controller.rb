class DocsController < ApplicationController
  include ParamParsing
  include IndexApi
  include LoadResults

  def index
    # Get the index results/docs to display
    query_index_results(params)

    # Save the docs and facets in vars and paginate
    load_result_docs_facets
  end

  def show
    id = params["id"]
    @doc = get_doc(ENV['PROJECT_INDEX'], id)
    @dataspec = get_dataspec_for_doc(@doc)
  end
end
