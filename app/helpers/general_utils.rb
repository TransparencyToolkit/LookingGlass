module GeneralUtils
  # Gets the human readable name of a field
  def getHR(name)
    @field_info.each do |i|
      if i["Form Params"] == name || i["Form Params"][0] == name || i["Form Params"][1] == name
        return i["Human Readable Name"]
      end
    end
  end

  # Generate link html 
  def genLink(name, path, em)
    return (em ? "<li><em>" : "<li>") + link_to(name, path) + (em ? "</li></em>" : "</li>")
  end

end
