module GeneralUtils
  # Gets the human readable name of a field
  def getHR(name, dataspec)
    dataspec.field_info.each do |i|
      if paramMatch?(i, name)
        return i["Human Readable Name"]
      end
    end
  end

  # Gets the search param name only- minus sindex
  def get_search_param(params)
    params.each do |key, value|
      # Find one that is search term
      if key.include?("_sindex_")
        key, index = key.split("_sindex_")

        # Get dataspec and item
        dataspec = @dataspecs_index_name[index]
        item = {key => value}
        return item, dataspec
      end
    end
  end

  # Gets the index and field name for date param
  def get_date_index(key)
    key, index = key.split("_sindex_")
    dataspec = @dataspecs_index_name[index]
    fieldname = key.split("range_")[1]

    return fieldname, dataspec
  end

  # Checks params for form params of all types
  def paramMatch?(pl_item, compare)
    form_params = pl_item["Form Params"]
    form_date_1 = pl_item["Form Params"][0]
    form_date_2 = pl_item["Form Params"][1]
    
    # Compare to both single item or array of params
    if compare.is_a? String
      return form_params == compare || form_date_1 == compare || form_date_2 == compare
    else
      return compare.keys.include?(form_params) || compare.keys.include?(form_date_1) || compare.keys.include?(form_date_2)
    end
  end

  # Generate link html 
  def genLink(name, path, em)
    return (em ? "<li><em>" : "<li>") + link_to(name, path) + (em ? "</li></em>" : "</li>")
  end

end
