# Saves the editable fields on DocManager
module SaveEditedFields

  # Saves the changed fields for the document
  def save_changed_fields(edited_fields)
    # Get the original document details and replace with new
    original_doc, doc_type = get_document_details(edited_fields)
    changed_doc = amend_document_hash(edited_fields, original_doc)
   
    # Save all documents in a thread
    thread_id_field = get_dataspec_for_doc(original_doc)["thread_id_field"]
    docs_for_thread = get_thread(ENV['PROJECT_INDEX'], original_doc["_source"][thread_id_field])
    
    # Save the edited document
    save_data(ENV['PROJECT_INDEX'], doc_type, [changed_doc])
  end

  # Get the document details
  def get_document_details(edited_fields)
    id = edited_fields["doc_id"]
    original_doc = get_doc(ENV['PROJECT_INDEX'], id)
    doc_type = get_dataspec_for_doc(original_doc)["class_name"]
    return original_doc, doc_type
  end

  # Change the document hash
  def amend_document_hash(edited_fields, original_doc)
    # Get changed fields and make a new version with them
    changed_fields = edited_fields["items"].to_h.to_a.select{|i| i[1]["edited"] == "true"}.map do |d|
      [d[0], d[1]["changed"]]
    end.to_h
    return original_doc["_source"].merge(changed_fields)
  end
end
