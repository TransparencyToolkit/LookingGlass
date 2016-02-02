module SearchedFormat
  # Renders the filters for the dataspec
  def render_filters
    outhtml = ""

    # Go through and add to output
    params.except("utf8", "action", "controller", "page").each do |k, v|
      # For facet params
      if k.include?("_facet")
        outhtml += process_facet_field(params, k, v)

      # For search all
      elsif k == "q"
        outhtml += removeFormat("All Fields", k, v, "search")

      # Search all in particular index
      elsif k.include?("all_sindex_")
        outhtml += process_allforindex_filter(params, k, v)

      # Check if it is a date
      elsif k.include?("startrange_") || k.include?("endrange_")
        outhtml += process_datefield_filter(k, v)

      # For a specific non-empty search term
      elsif params[k] != ""
        outhtml += process_searchfield_filter(params, k, v)
      end
    end

    return raw(outhtml)
  end

  # Generates remove links for facet fields
  def process_facet_field(params, k, v)
    outhtml = ""

    # Handle multiple sets of facets
    if v.is_a?(Array)
      v.each do |v1|
        outhtml += removeFormat(get_facet_hrname(k), k, v1, "filter")
      end
    else
      # Handle single facets
      outhtml += removeFormat(get_facet_hrname(k), k, v, "filter")
    end

    return outhtml
  end

  def get_facet_hrname(k)
    # Get field display details
    field_spec = getFieldDetails(k.to_s.gsub("_facet", ""), @all_field_info)

    # Get facet hrname
    return field_spec["Human Readable Name"]
  end

  # Processes the filter for the index
  def process_allforindex_filter(params, k, v)
    _, dataspec = get_search_param(params)
    dataset_name = dataspec.dataset_name
    hrname = "All " + dataset_name
    return removeFormat(hrname, k, v, "search")
  end

  # Generates filter for date field queries
  def process_datefield_filter(k, v)
    param_item, dataspec = get_date_index(k)
    dataset_name = dataspec.dataset_name
    hrname = getHR(param_item, dataspec)+" "+ check_start_or_end(k)+" ("+dataset_name+")"
    return removeFormat(hrname, k, v, "search")
  end

  # Checks if it is the start or end date of range
  def check_start_or_end(k)
    if k.include?("startrange_")
      return "Later Than"
    elsif k.include?("endrange_")
      return "Earlier Than"
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
    outstr += '<span class="category">' + hrname + " ["+type+"] </span>"
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
    return params.except("page").except("action").except("controller").except("utf8").length <= 1 && (!params[k].is_a?(Array) || params[k].length <= 1)
  end

  # Generates the x link with the appropriate path
  def genXLink(path)
    return link_to(raw('X'), path, :class => "remove-filter")
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
