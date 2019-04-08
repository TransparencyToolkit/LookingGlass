class DocsController < ApplicationController
  include ParamParsing
  include IndexApi
  include LoadResults
  include ThreadDocs
  include SaveEditedFields

  def index
    # Get the index results/docs to display
    query_index_results(params)

    # Save the docs and facets in vars and paginate
    load_result_docs_facets
  end

  def show
    id = handle_legacy_id(params["id"])
    @doc = get_doc(ENV['PROJECT_INDEX'], id)
    @dataspec = get_dataspec_for_doc(@doc)
    @thread_docs = get_docs_in_thread(@doc)
    @thread_fields, @item_fields = split_fields_into_thread_and_item_fields(@thread_docs, @dataspec)
  end

  # Handle attachments in directories other than the current one
  def attach
    # Set the path depending on if there is extension
    if params["format"]
      path = "/"+params["path"]+"."+params["format"]
    else
      path = "/"+params["path"]
    end
    mime_type = get_mime_type(path)

    send_file(path,
              :disposition => 'inline',
              :type => mime_type,
              :x_sendfile => true )
  end

  # Update a document that was edited
  def edit_document
    if ENV['WRITEABLE'] == "true"
      save_changed_fields(params["edited"])
      status = "success"
      message = "Document edited successfully"
    else
      status = "error"
      message = "Not WRITABLE Deleting documents disabled"
    end
    render :json => { status: status, message: message }
  end

  def delete_documents
    if ENV['WRITABLE'] == "true"
      status = "success"
      message = "Yay a DELETE request happened :)"
    else
      status = "error"
      message = "Not WRITABLE Deleting documents disabled"
    end
    render :json => { status: status, message: message }
  end

  private

  # Get the mime type
  def get_mime_type(path)
    FileMagic.open(:mime) do |fm|
      return fm.file(path).split(";")[0]
    end
  end

  # Process the ID to handle legacy formats
  def handle_legacy_id(id)
    if id.include?("nsadocs") && !id.include?("_nsadocs_snowden_doc")
      return id.gsub("nsadocs", "_nsadocs_snowden_doc")
    elsif ENV['PROJECT_INDEX'] == "icwatch"
      # Remap FBIDHS dataset ID
      if !id.include?("icwatch") && id.include?("fbidhs")
        return id.gsub("fbidhs", "_icwatch_fbidhs")
      # Remap LI dataset ID
      elsif id.include?("icwatch_linkedin") && !id.include?("_icwatch_linkedin")
        return id.gsub("icwatch_linkedin", "_icwatch_linkedin")
      # Remap Indeed dataset ID
      elsif id.include?("icwatch_indeed") && !id.include?("_icwatch_indeed")
        return id.gsub("icwatch_indeed", "_icwatch_indeed").gsub("?sp=0", "sp=0")
      else
        return id
      end
    else
      return id
    end
  end
end
