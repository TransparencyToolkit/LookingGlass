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
      elsif field_searched.include?("_facet")
        outhtml += render_facet_filters(field_searched, query)
      end
    end

    return raw(outhtml)
  end

  # Show filters for facet vals
  def render_facet_filters(field_searched, query)
    human_readable_name = human_readable_title(get_facets_for_project(ENV["PROJECT_INDEX"])[field_searched.gsub("_facet", "")])
    query_array = query.is_a?(Array) ? query : [query]
    
    return query_array.inject("") do |outhtml, filter_query|
      outhtml += render partial: "search/search_filters/filter", locals: { query: filter_query,
                                                                           field_searched: field_searched,
                                                                           label: "#{human_readable_name} [filter]"}
    end
  end

  # Generates the appropriate remove link for the situation DUPLICATE
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

  # Checks if it is the last search term or not DUPLICATE
  def last_search_term?(field_searched)
    return params.except("utf8", "action", "controller", "page", "c", "a").length <= 1 &&
           (!params[field_searched].is_a?(Array) || params[field_searched].length <= 1)
  end

  # Generates the x link with the appropriate path
  def gen_x_link(path)
    return link_to(raw('X'), path, :class => "remove-filter")
  end

  # Link removes just one val if multiple are chosen DUPLICATE
  def mult_vals_selected(field_searched, query)
    path = remove_without_removing_other_params(query, params[field_searched], field_searched)
    return gen_x_link(path)
  end
end
