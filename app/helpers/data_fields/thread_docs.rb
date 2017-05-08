# Helper methods for threading documents and managing item fields in the results
module ThreadDocs
  # Group the documents and return them in a threaded list
  def thread_docs_in_results(docs)
    return docs.group_by{|doc| doc["_source"]["thread_id"]}.values
  end

  # Get the overall fields and the fields for each item
  def split_fields_into_thread_and_item_fields(docs)
    # Get the threads that are the same across all docs
    overall_thread_fields = docs.map{|doc| doc["_source"].to_a}.reduce(:&).to_h

    # Find the fields that differ for each doc and keep source headers
    item_fields = docs.map do |doc|
      doc["_source"] = doc["_source"].except(*overall_thread_fields.keys)
      doc
    end.delete_if{|field| field["_source"].blank?}
    overall_thread_fields = docs.first.except("_source").merge("_source" => overall_thread_fields)
    
    return overall_thread_fields, item_fields
  end
end
