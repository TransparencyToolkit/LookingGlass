module IndexApi
  def get_docs_on_index_page(start, index_name)
    http = Curl.get("http://localhost:3000/get_docs_on_index_page", {:start => start, :index_name => index_name})
    return JSON.parse(http.body_str)
  end

  def get_total_docs(index_name)
    http = Curl.get("http://localhost:3000/get_total_docs", {:index_name => index_name})
    return JSON.parse(http.body_str)
  end

  def get_dataspec_for_doc(doc)
    index_name = doc["_index"]
    http = Curl.get("http://localhost:3000/get_dataspec_for_doc", {:index_name => index_name, :doc => JSON.generate(doc)})
    return JSON.parse(http.body_str)
  end

  def get_project_spec(index_name)
    http = Curl.get("http://localhost:3000/get_project_spec", {:index_name => index_name})
    return JSON.parse(http.body_str)
  end
end
