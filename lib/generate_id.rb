require 'index_manager.rb'

module GenerateId
  # Get unique ID
  def getID(item)
    # If some part should be removed from the ID field
    id_initial = item[@id_field.to_sym] == nil ? item[@id_field] : item[@id_field.to_sym]
    if @get_after != nil && !@get_after.empty?
      clean_id = cleanID(id_initial.split(@get_after)[1])
    else
      clean_id = cleanID(id_initial)
    end

    @id_secondary.each do |f|
      secondary_field = item[f.to_sym] == nil ? item[f] : item[f.to_sym]
      clean_id += cleanID(secondary_field.to_s) if secondary_field != nil
    end

    return clean_id
  end

  # Removes non-urlsafe chars from ID
  def cleanID(str)
    if str
      return str.gsub("/", "").gsub(" ", "").gsub(",", "").gsub(":", "").gsub(";", "").gsub("'", "").gsub(".", "")
    end
  end
end
