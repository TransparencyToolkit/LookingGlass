module VersionControl
  # See if any docs changes
  def any_changed?(docs)
    docs.each do |doc|
      return true if doc["_source"]["doc_modified"] == "Changed"
    end

    return false
  end

  # Return newest and oldest docs
  def get_newest_and_oldest(doc)
    # Get versions and field to compare by
    versions = doc["versions"]
    timestamp_field = @dataspec.dedup_prioritize

    # Set to defaults
    newest_version = versions.first
    oldest_version = versions.last

    # Change until appropriate timestamp
    versions.each do |version|
      newest_version = version if version[timestamp_field] > newest_version[timestamp_field]
      oldest_version = version if version[timestamp_field] < oldest_version[timestamp_field]
    end

    return newest_version, oldest_version
  end

  
end
