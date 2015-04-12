module GeneralUtils
  # Gets the human readable name of a field
  def getHR(name)
    @field_info.each do |i|
      if paramMatch?(i)
        return i["Human Readable Name"]
      end
    end
  end

  # Checks params for form params of all types
  def paramMatch?(p_item)
    return p_item["Form Params"] == name || p_item["Form Params"][0] == name || p_item["Form Params"][1] == name
  end

  # Generate link html 
  def genLink(name, path, em)
    return (em ? "<li><em>" : "<li>") + link_to(name, path) + (em ? "</li></em>" : "</li>")
  end

end
