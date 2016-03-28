require 'index_manager.rb'

module GenerateId
  # Get unique ID from formatted primary and secondary fields
  def getID(item, dataspec)
    id_initial = item[set_name(dataspec.id_field, item)]
    clean_id = cleanID(removeIDPart(id_initial, dataspec))
    return addIndex(appendSecondary(clean_id, item, dataspec), dataspec)
  end

  # Add index name to id iff more than one dataset
  def addIndex(id, dataspec)
    return id+dataspec.index_name
  end

  # Append secondary ID fields
  def appendSecondary(clean_id, item, dataspec)
    dataspec.id_secondary.each do |f|
      secondary_field = item[set_name(f, item)]
      clean_id += cleanID(secondary_field.to_s) if secondary_field != nil
    end

    return clean_id
  end
  
  # Remove part of ID if needed              
  def removeIDPart(id_initial, dataspec)
    if dataspec.get_after != nil && !dataspec.get_after.empty?
      id_initial = id_initial.split(dataspec.get_after)[1]
    end

    return id_initial
  end

  # Removes non-urlsafe chars from ID
  def cleanID(str)
    if str
      return str.gsub("/", "").gsub(" ", "").gsub(",", "").gsub(":", "").gsub(";", "").gsub("'", "").gsub(".", "")
    end
  end
end
