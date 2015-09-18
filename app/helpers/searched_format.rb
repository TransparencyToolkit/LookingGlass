module SearchedFormat
  # Renders the filters for the dataspec
  def render_filters
    params.except("utf8", "action", "controller", "page").each do |k, v|
      # For facet params
      if k.include?("_facet")
        # ADD FACET PROCESSING
      # For search all
      elsif k == "q"
        return raw(removeFormat("All Fields", k, v, "search"))
      # For a specific non-empty search term
      elsif params[k] != ""
        return raw(process_searchfield_filter(params, k, v))
      end
    end
  end

  # Generates filter for search by field
  def process_searchfield_filter(params, k, v)
    param_item, dataspec = get_search_param(params)
    field_key = param_item.keys.first
    dataset_name = dataspec.dataset_name
    hrname = getHR(field_key, dataspec)+" ("+dataset_name+")"
    return removeFormat(hrname, k, v, "search")
  end
  
  # Formats the x link for search terms (link removes term from search) 
  def removeFormat(hrname, k, v, type)
    outstr = '<div class="search-filter">'
    outstr += '<span class="filter">' + strip_tags(v) + '</span>'
    outstr += getRemoveLink(k, v)
    outstr += '<br>'
    outstr += '<span class="category">' + hrname + "</span>"
    outstr += '</div>'
  end

  # Generates the appropriate remove link for the situation
  def getRemoveLink(k, v)
    # If it's the last search term, go back to main page
    if lastSearchTerm?(k)
      return genXLink(docs_path)
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
