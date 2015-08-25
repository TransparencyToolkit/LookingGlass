module DeduplicateData
  # Deduplicate Items
  def deduplicate(item)
    # Check if any item from same profile has been added
    potential_dups = Doc.search(query: { match: { @id_field => item[@id_field] }}).results

    # Check if there are any entries for that item
    if !potential_dups.empty?
      potential_dups.each do |dup_i|
        # See if it is exact match or not
        if exactMatch?(removeIgnore(item).symbolize_keys, removeIgnore(dup_i.to_hash))
          # Check if matching item was scraped after saved item
          if Date.parse(item[@dedup_prioritize]) > Date.parse(dup_i[@dedup_prioritize].to_s)
            return true # TODO: Delete the old item and create a new one instead
          else
            return false # Existing item is more recent
          end
        else
          return true # A different entry for same item
        end
      end
    else
      return true # No other entries for item
    end
  end
  
  # Remove ignore fields for comparison
  def removeIgnore(item)
    itemcopy = item.dup
    @dedup_ignore.each do |remove|
      itemcopy = itemcopy.except(remove, remove.to_sym)
    end

    return itemcopy
  end

  # See if all the fields in first item match all the fiels in the second item
  def exactMatch?(first_item, second_item)
    first_item.each do |key, value|
      # Checks if it is a date, not nil, and not a year
      if second_item[key]
        if isDate?(key.to_s) && value != nil && value.length > 4
          # Sometimes end dates are different for same position- this is a bug
        elsif value == nil
          return false if !second_item[key] == nil
        elsif value.is_a?(Integer) || value.is_a?(Float)
          return false if value.to_i != second_item[key].to_i
        elsif !value.is_a?(Integer) && value.empty?
          return false if value.empty? && (second_item[key] != nil && !second_item[key].empty?)
        elsif second_item[key] != value
          return false
        end
      end
    end
    return true

  end
end
