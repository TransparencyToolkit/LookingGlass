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
    overall_thread_fields = append_never_item_fields(docs, dataspec, overall_thread_fields)
    overall_thread_fields = add_doc_versions_to_overall(docs, overall_thread_fields)
    
    # Find the fields that differ for each doc and keep source headers
    item_fields = docs.map do |item|
      item["_source"]["doc_versions"] = filter_version_fields(overall_thread_fields.keys, item["_source"]["doc_versions"], "exclude")
      item["_source"] = item["_source"].except(*(overall_thread_fields.keys-["doc_versions", "version_changed"]))
      item
    end.delete_if{|field| field["_source"].blank?}

    # Finish preparing overall_thread_fields to be formatted like a doc
    overall_thread_fields = docs.first.except("_source").merge("_source" => overall_thread_fields)
    
    # Sort and return
    return overall_thread_fields, sort_thread_items(item_fields, dataspec)
  end

  # Filter an array of doc_versions to only include specified fields (used for both overall and item fields)
  def filter_version_fields(fields_to_check, doc_versions, incl_excl)
    return doc_versions.map do |version|
      if incl_excl == "exclude"
        filtered = version.except(*fields_to_check)
      elsif incl_excl == "include"
        filtered = version.select{|k, v| fields_to_check.include?(k)}
      end
      filtered
    end.uniq
  end

  # Add list of versions to overall thread fields
  def add_doc_versions_to_overall(docs, overall_thread_fields)
    # Get a list of doc versions of just overall fields
    doc_overall_versions = docs.map do |item|
      filter_version_fields(overall_thread_fields.keys, item["_source"]["doc_versions"], "include")
    end

    # Parse and merge version list, flag changed if multiple
    version_list = doc_overall_versions.uniq.compact.flatten.uniq
    if (version_list.length > 1) && any_changed?(docs)
      overall_thread_fields = overall_thread_fields.merge({"version_changed" => "Changed"})
    end
    return overall_thread_fields.merge({"doc_versions" => version_list})
  end

  # Check if any docs were changed
  def any_changed?(docs)
    docs.map{|d| d["_source"]["version_changed"]}.include?("Changed")
  end

  # Append the fields that are never item fields to the overall_thread_fields
  def append_never_item_fields(docs, dataspec, overall_thread_fields)
    dataspec["never_item_fields"].each do |field|
      values = docs.map{|doc| doc["_source"][field] }.uniq.compact
      overall_thread_fields = overall_thread_fields.merge({field => values.first})
    end
    overall_thread_fields
  end

  # Sort the item fields by the sort field and order specified in the dataspec
  def sort_thread_items(item_fields, dataspec)
      sorted = item_fields.sort do |a, b|
        if a["_source"][dataspec["sort_field"]] &&  b["_source"][dataspec["sort_field"]]
          a["_source"][dataspec["sort_field"]] <=> b["_source"][dataspec["sort_field"]]
        else
          -1
        end
      end.reverse
    sorted = sorted.reverse if dataspec["sort_order"] == "asc"
   
    return sorted
  end

  # Get the docs in the same thread for the show page
  def get_docs_in_thread(doc)
    thread_id = doc["_source"]["thread_id"]
    return get_thread(ENV['PROJECT_INDEX'], thread_id)
  end
end
