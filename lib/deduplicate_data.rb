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
      # Compare the two fields for that same key against each other
      if second_item[key]
        matching = fieldValsMatch?(value, second_item[key], key)
        return matching if !matching
      end
    end
    return true # If all match
  end

  # Return false if the two fields don't match 
  def fieldValsMatch?(first_val, second_val, key)
    # Check if it is a date, not nil, and not a year
    if isDate?(key.to_s) && first_val != nil && first_val.length > 4
    elsif first_val == nil # Check if both are nil
      return false if bothNotNil?(second_val)
    elsif isNonIntNum?(first_val) # Check if they match when converted to int
      return false if !matchAsInt?(first_val, second_val)
    elsif isEmpty?(first_val) # Check if both are empty
      return false if !isEmpty?(second_val)
    elsif simplyDoesntMatch?(first_val, second_val) # Check if they match
      return false
    end
  end

  # Returns true if it doesn't match
  def simplyDoesntMatch?(value, second_item, key)
    return second_item != value
  end

  # Checks if val is in int or float
  def isNonIntNum?(value)
    return value.is_a?(Integer) || value.is_a?(Float)
  end

  # Checks if value is empty
  def isEmpty?(value)
    return !value.is_a?(Integer) && (value != nil) && value.empty?
  end

  # Checks if num values match after being converted to same type
  def matchAsInt?(value, second_item)
    return value.to_i != second_item.to_i
  end
  
  # Check if both are nil (and return false/no match if not)
  def bothNotNil?(second_item)
    return !second_item == nil
  end
end
