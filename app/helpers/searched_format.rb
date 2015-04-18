module SearchedFormat
  # Formats the x link for search terms (link removes term from search) 
  def removeFormat(hrname, k, v, type)
    outstr = '<div class="search-filter">'
    outstr += '<span class="filter">' + v + '</span>'
    outstr += getRemoveLink(k, v)
    outstr += '<br>'
    outstr += '<span class="category">' + hrname + "</span>"
    outstr += '</div>'
  end

  # Generates the appropriate remove link for the situation
  def getRemoveLink(k, v)
    # If it's the last search term, go back to main page
    if lastSearchTerm?(k)
      return genXLink(nsadocs_path)
    else
      # Check if one or more vals are chosen
      if params[k].is_a? Array
        return multValsSelected(k, v)
      else # For single vals per category
        return genXLink(search_path(params.except(k)))
      end
    end
  end

  # Checks if it is the last search term or not
  def lastSearchTerm?(k)
    return params.except("page").length <= 4 && (!params[k].is_a?(Array) || params[k].length <= 1)
  end

  # Generates the x link with the appropriate path
  def genXLink(path)
    return link_to(raw('<b style="color: red" class="x"> X</b>'), path, :class => "remove-filter")
  end

  # Link removes just one val if multiple are chosen
  def multValsSelected(k, v)
    saveparams = params[k]
    params[k] = params[k] - [v] # Remove value from array                                                 
    link = genXLink(search_path(params))
    params[k] = saveparams # Set it back to normal
    return link
  end
end
