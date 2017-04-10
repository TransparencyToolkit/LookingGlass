module ParamFilters
  # Renders the filters for the dataspec
  def render_filters
    outhtml = ""

    # Go through and add to output
    params.except("utf8", "action", "controller", "page", "c", "a").each do |field_searched, query|
      # For search all
      if field_searched == "q"
        outhtml += render partial: "search/search_filters/filter", locals: { query: query,
                                                                  field_searched: field_searched,
                                                                  label: "All Fields [search]"}
      end
    end

    return raw(outhtml)
  end

  # Generates the appropriate remove link for the situation
  def gen_remove_link(field_searched, query)
    # If it's the last search term, go back to main page
    if last_search_term?(field_searched)
      return gen_x_link(docs_path)
    else
      # Check if one or more vals are chosen
      if params[field_searched].is_a? Array
        return mult_vals_selected(field_searched, query)
      else # For single vals per category
        return gen_x_link(search_path(params.symbolize_keys.except(field_searched.to_sym)))
      end
    end
  end

  # Checks if it is the last search term or not
  def last_search_term?(field_searched)
    return params.except("utf8", "action", "controller", "page", "c", "a").length <= 1 &&
           (!params[field_searched].is_a?(Array) || params[field_searched].length <= 1)
  end

  # Generates the x link with the appropriate path
  def gen_x_link(path)
    return link_to(raw('X'), path, :class => "remove-filter")
  end

  # Link removes just one val if multiple are chosen
  def mult_vals_selected(field_searched, query)
    saveparams = params[field_searched]
    params[field_searched] = params[field_searched] - [query] # Remove value from array
    link = gen_x_link(search_path(params))
    params[field_searched] = saveparams # Set it back to normal
    return link
  end
end
