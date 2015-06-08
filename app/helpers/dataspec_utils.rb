module DataspecUtils
  # Load all dataspec info
  def loadDataspec
    getFieldInfo
    getDisplayPrefs
  end

  # Gets the details for each field
  def getFieldInfo
    @importer = JSON.parse(File.read("app/dataspec/importer.json")).first
    @field_info = JSON.parse(File.read(@importer["Data Template"]))
    @field_info_sorted = @field_info.sort_by{|field| field["Location"].to_i}
  end

  # Get where each field should show up                                                                           
  def getDisplayPrefs
    display_prefs = JSON.parse(File.read(@importer["Field Locations"]))
    @facet_fields = display_prefs["Facet"]
    @searchable_fields = display_prefs["Searchable"]
    @fields_in_results = display_prefs["In Search Results"]
    @default_fields_in_results = display_prefs["In Search Results by Default"]
    @doc_page_fields = display_prefs["On Doc Page"]
    @item_fields = display_prefs["Item Field"]
    @truncated_fields = display_prefs["Truncate Text"]
  end

  # Takes name and gets field details
  def getFieldDetails(name)
    @field_info.each do |i|
      if name == i["Field Name"]
        return i
      end
    end
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
  def sortFields(field_list)
    filtered_fields = Hash.new

    # Go through each field in field list and find in field_info json                                                                  
    field_list.each do |field|
      @field_info.each do |field_info|
        # Save field name and location                                                                                                 
        filtered_fields[field] = field_info["Location"].to_i if field_info["Field Name"] == field
      end
    end

    # Sort by values and then return list of just keys                                                                                
    return filtered_fields.sort_by{|k, v| v}.collect{|i| i[0]}
  end
end
