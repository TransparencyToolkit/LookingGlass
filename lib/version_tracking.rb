module VersionTracking   
  # Add new version of document to version list
  def add_new_version(version_item, dataspec, doc_class, id)
    # Get full item and timestamps
    full_item = doc_class.find(id)
    full_item_timestamp = full_item[dataspec.dedup_prioritize]
    version_timestamp = version_item[dataspec.dedup_prioritize]

    # Update main item to be newest
    if full_item_timestamp <= version_timestamp
      full_item = full_item.update(version_item)
    end

    update_item_for_new_version(full_item, version_item, dataspec, doc_class, id)
  end

  # Make an entirely new item
  def create_new(item, dataspec, doc_class, id)
    created_item = doc_class.create item.merge(id: id), index: dataspec.index_name
    
    update_item_for_new_version(created_item, item, dataspec, doc_class, id)
  end

  # Update item to match new version
  def update_item_for_new_version(full_item, item, dataspec, doc_class, id)
    # Add new version
    append_version_to_item(item, doc_class, id)
    add_this_version_to_list(item, doc_class, id, dataspec)

    # Check if document has been changed
    change_status = check_changed(item, dataspec, doc_class, id)
    doc_class.find(id).update(doc_modified: change_status, doc_modified_facet: change_status)

    # Merge categorical fields in versions
    merge_categorical_overall(doc_class, id, dataspec)
  end

  # Merge categorical fields in overall item
  def merge_categorical_overall(doc_class, id, dataspec)
    # Go through all fields
    dataspec.merge_categorical_fields.each do |field|
      doc = doc_class.find(id)
      merged_values = []

      # Merge fields from each version
      doc[:versions].each do |version|
        field_val = version[field].is_a?(Array) ? version[field] : [version[field]]
        merged_values = merged_values | field_val
      end

      # Update field and facet field
      doc_class.find(id).update(field => merged_values, (field+"_facet").to_sym => merged_values)
    end
  end

  # Add this version to the list of versions
  def add_this_version_to_list(item, doc_class, id, dataspec)
    version_list = doc_class.find(id).version_list
    this_version = item[dataspec.dedup_prioritize]
    
    # Push to existing list if existing, otherwise make new
    if version_list
      doc_class.find(id).update(version_list: version_list.push(this_version))
    else
      doc_class.find(id).update(version_list: [this_version])
    end
  end

  # Append a new version to the versions nested document
  def append_version_to_item(item, doc_class, id)
    all_versions = doc_class.find(id).versions

    # Push to existing list if existing, otherwise make new arr
    if all_versions
      doc_class.find(id).update(versions: all_versions.push(item))
    else
      doc_class.find(id).update(versions: [item])
    end
  end


  # Remove ignore fields for comparison
  def removeIgnore(item, dataspec)
    itemcopy = item.dup
    dataspec.dedup_ignore.each do |remove|
      itemcopy = itemcopy.except(remove, remove.to_sym)
    end

    return itemcopy
  end

  # See if document has been changed or deleted
  def check_changed(item, dataspec, doc_class, id)
    versions = doc_class.find(id).versions

    doc_modified = doc_class.find(id)[:doc_modified]
    return doc_modified if doc_modified

    versions.each do |version|
      # Make copy and remove current version
      other_versions = versions.dup
      other_versions.delete(version)

      # Check if exactly the same as all other versions
      other_versions.each do |other_version|
        # Remove timestamp and other fields that may change without doc changing
        nonchanging_version = removeIgnore(version, dataspec).symbolize_keys
        nonchanging_other_version = removeIgnore(other_version, dataspec).symbolize_keys

        nonchanging_version.each do |key, value|
          return "Changed" if value != nonchanging_other_version[key]
        end
      end

      return "Not Changed"
    end
  end
end
