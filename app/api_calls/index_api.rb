module IndexApi
  def get_child_documents(doc, field)
    doc_id = doc["_id"]
    index_name = doc["_index"]
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_child_documents", {:doc_id => doc_id, :field => field, :index_name => index_name})
    return JSON.parse(http.body_str)
  end

  def get_docs_on_index_page(start, index_name)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_docs_on_index_page", {:start => start, :index_name => index_name})
    return JSON.parse(http.body_str)
  end

  def get_total_docs(index_name)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_total_docs", {:index_name => index_name})
    return http.body_str
  end

  def get_doc(index_name, doc_id)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_doc", {:index_name => index_name, :doc_id => doc_id})
    return JSON.parse(http.body_str)
  end

  def get_thread(index_name, thread_id)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_docs_in_thread", {:index_name => index_name, :thread_id => thread_id})
    return JSON.parse(http.body_str)
  end

  def get_dataspec_for_doc(doc)
    index_name = doc["_index"]
    doc_type = doc["_type"]
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_dataspec_for_doc", {:index_name => index_name, :doc_type => doc_type})
    return JSON.parse(http.body_str)
  end

  def get_project_spec(index_name)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_project_spec", {:index_name => index_name})
    return JSON.parse(http.body_str)
  end

  def get_facet_list_divided_by_source(index_name)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_facet_list_divided_by_source", {:index_name => index_name})
    return JSON.parse(http.body_str)
  end

  def get_dataspecs_for_project(index_name)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_dataspecs_for_project", {:index_name => index_name})
    return JSON.parse(http.body_str)
  end

  def get_facets_for_project(index_name)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/get_facet_details_for_project", {:index_name => index_name})
    return JSON.parse(http.body_str)
  end

  def run_query(index_name, search_query, range_query, start_offset, facets)
    http = Curl.get("#{ENV['DOCMANAGER_URL']}/run_query", {:index_name => index_name,
                                                        :search_query => search_query,
                                                        :range_query => range_query,
                                                        :start => start_offset,
                                                        :facet_params => facets
                                                        })
    return JSON.parse(http.body_str)
  end

  # Save the data, such as after editing a document
  def save_data(index_name, dataspec, doc_data)
    c = Curl::Easy.new("#{ENV['DOCMANAGER_URL']}/add_items")
    c.http_post(Curl::PostField.content("item_type", dataspec),
                Curl::PostField.content("index_name", index_name),
                Curl::PostField.content("items", JSON.pretty_generate(doc_data)))
    return JSON.parse(c.body_str)
  end

  # Delete documents from elastic (pass array of documents to delete)
  def delete_documents(array_of_documents)
    c = Curl::Easy.new("#{ENV['DOCMANAGER_URL']}/remove_items")
    c.http_post(Curl::PostField.content("items", JSON.pretty_generate(array_of_documents)))
  end

  # Add a field to dataspec in DocManager
  # Requires passing dataspec name (camelcase name like ArchiveTestDoc), index name, machine readable param name, and field params of following format:
  # {display_type: "Category", icon: "document", human_readable: "Human Readable Field Name"}
  # The human readable name, icon, display type, and dataspec to use should be collected from the user
  # The dataspec name, index name, machine readable name should be automatically set based on the input (and field_hash reformatted)
  def add_field(doc_class, project_index, machine_readable_param, field_hash)
    c = Curl::Easy.new("#{ENV['DOCMANAGER_URL']}/add_field")
    c.http_post(Curl::PostField.content("doc_class", doc_class),
                Curl::PostField.content("project_index", project_index),
                Curl::PostField.content("field_name", machine_readable_param),
                Curl::PostField.content("field_hash", JSON.pretty_generate(field_hash)))
  end
end
