# Tracks the version of the documents
module VersionTracker
  # Show the versioned doc, with change tracker if it has been changed
  def show_versioned_doc(doc, is_item_field=false)
    # Render in change tracker
    if (doc["_source"]["version_changed"] == "Changed") && actually_changed?(doc)
      newest, oldest = get_newest_and_oldest_versions(doc)
      render partial: 'docs/show/tabs/panes/text_partials/changetracker', locals: {
             to_render: 'docs/show/tabs/panes/text_partials/text_fields',
             newest_doc: {"_source" => newest},
             oldest_doc: {"_source" => oldest},
             doc_id: doc["_id"].gsub(/[^0-9a-z ]/i, '-'),
             is_item_field: is_item_field}
     
    else # Render fields normally
      render partial: 'docs/show/tabs/panes/text_partials/text_fields', locals: {doc: doc, is_item_field: is_item_field}
    end
  end

  # Check if the fields on the list to check for actually changed
  def actually_changed?(doc)
    just_fields_to_track = doc["_source"]["doc_versions"].map do |version|
      version.select{|field| @dataspec["fields_to_track"].include?(field)}
    end
    
    # Check if difference is due to formatting changes
    # This is needed in case of a formatting change in an item field when real changes are just in overall fields
    @dataspec["fields_to_track"].each do |field|
      field_vals = just_fields_to_track.uniq.map{|version| version[field].to_s.gsub(/[^0-9a-z]/i, "")}
      return true if field_vals.uniq.length > 1
    end

    return false
  end
  
  # Get the newest and oldest versions
  def get_newest_and_oldest_versions(doc)
    # Remap to just check item fields
    keys_to_keep = doc["_source"].keys << @dataspec["most_recent_timestamp"]
    remapped_docs = doc["_source"]["doc_versions"].map{|version| version.reject{|key, value| !keys_to_keep.include?(key)}}    
    
    # Sort and return most recent
    sorted_versions = remapped_docs.sort_by{|version| version[@dataspec["most_recent_timestamp"]]}
    return sorted_versions.last, sorted_versions.first
  end
end
