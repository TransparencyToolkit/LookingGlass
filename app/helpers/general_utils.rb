module GeneralUtils
  # Gets the human readable name of a field
  def getHR(name)
    @field_info.each do |i|
      if paramMatch?(i, name)
        return i["Human Readable Name"]
      end
    end
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
      return compare.include?(form_params) || compare.include?(form_date_1) || compare.include?(form_date_2)
    end
  end

  # Generate link html 
  def genLink(name, path, em)
    return (em ? "<li><em>" : "<li>") + link_to(name, path) + (em ? "</li></em>" : "</li>")
  end

end
