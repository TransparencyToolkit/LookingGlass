module DataspecUtils
  # Takes name and gets field details
  def getFieldDetails(name, field_details)
    field_details.each do |i|
      if name == i["Field Name"]
        return i
      end
    end

    # No matching field- this is an error with the dataspec
    return nil
  end

  # Takes a field and list to check it against                                                   
  def checkIfX(field, list)
    if list == nil
      return false
    else
      return list.include?(field["Field Name"]) ? true : false
    end
  end

  # Sorts lists of fields                                                                                                  
  def sortFields(field_list, field_details)
    filtered_fields = Hash.new

    # Go through each field in field list and find in field_info json                                                                  
    field_list.each do |field|
      field_details.each do |field_info|
        # Save field name and location                                                                                                 
        filtered_fields[field] = field_info["Location"].to_i if field_info["Field Name"] == field.to_s
      end
    end

    # Sort by values and then return list of just keys                                                                                
    return filtered_fields.sort_by{|k, v| v}.collect{|i| i[0]}
  end
end
