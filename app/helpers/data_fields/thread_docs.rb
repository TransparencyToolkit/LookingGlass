# Helper methods for threading documents and managing item fields in the results
module ThreadDocs
  # Group the documents and return them in a threaded list
  def thread_docs_in_results(docs)
    return docs.group_by{|doc| doc["_source"]["thread_id"]}.values
  end

  # Get the overall fields and the fields for each item
  def split_fields_into_thread_and_item_fields(docs, dataspec)
    # Get the threads that are the same across all docs
    overall_thread_fields = docs.map{|doc| doc["_source"].to_a}.reduce(:&).to_h

    # Find the fields that differ for each doc and keep source headers
    item_fields = docs.map do |doc|
      doc["_source"] = doc["_source"].except(*overall_thread_fields.keys)
      doc
    end.delete_if{|field| field["_source"].blank?}
    overall_thread_fields = docs.first.except("_source").merge("_source" => overall_thread_fields)

    # Sort and return
    return overall_thread_fields, sort_thread_items(item_fields, dataspec)
  end

  # Sort the item fields by the sort field and order specified in the dataspec
  def sort_thread_items(item_fields, dataspec)
    sorted = item_fields.sort_by{|doc| doc["_source"][dataspec["sort_field"]]}
    sorted = sorted.reverse if dataspec["sort_order"] == "asc"
    return sorted
  end

  # Get the docs in the same thread for the show page
  def get_docs_in_thread(doc)
    thread_id = doc["_source"]["thread_id"]
    return get_thread(ENV['PROJECT_INDEX'], thread_id)
  end
end
