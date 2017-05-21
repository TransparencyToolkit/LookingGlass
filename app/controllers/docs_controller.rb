class DocsController < ApplicationController
  include ParamParsing
  include IndexApi
  include LoadResults
  include ThreadDocs

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
    @thread_docs = get_docs_in_thread(@doc)
    @thread_fields, @item_fields = split_fields_into_thread_and_item_fields(@thread_docs, @dataspec)
  end

  # Handle attachments in directories other than the current one
  def attach
    path = "/"+params["path"]+"."+params["format"]
    send_file(path,
              :disposition => 'inline',
              :type => "application/pdf",
              :x_sendfile => true )
  end
end
