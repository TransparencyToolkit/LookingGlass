module SearchedFormat
  # Formats the x link for search terms (link removes term from search) 
  def removeFormat(hrname, k, v, type)
    outstr = '<span class="search-filter">'
    outstr += hrname+": "+ v + " (" + type + ")"

    # Generate appropriate link 
    if lastSearchTerm?(k)
      outstr += genXLink(nsadocs_path)
    else
      # Check if one or more vals are chosen
      if params[k].is_a? Array
        outstr += multValsSelected(k, v)
      else # For single vals per category                                           
        outstr += genXLink(search_path(params.except(k)))
      end
    end

    outstr += '</span>'
  end

  # Checks if it is the last search term or not
  def lastSearchTerm?(k)
    return params.length <= 4 && (!params[k].is_a?(Array) || params[k].length <= 1)
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
