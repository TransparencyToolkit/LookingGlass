module ParamFilters
  # Renders the filters for the search params
  def render_filters
    # Go through and add to output
    return params.except(*@params_to_ignore).inject("") do |out_html, param|
      field_searched, query = param[0], param[1]
      
      # Generate the labels and parse queries for param
      if field_searched == "q"
        filters = generate_filter_info_hash(query, "All Fields [search]")
      elsif field_searched.include?("_facet")
        filters = render_facet_filters(field_searched, query)
      elsif field_searched.include?("startrange_") || field_searched.include?("endrange_")
        filters = generate_date_filter(field_searched, query)
      elsif field_searched != ""
        filters = generate_search_filter(field_searched, query)
      end

      # Render the filter for the param (also for multiple facets)
      out_html += filters.inject("") do |html, filter|
        html += render_filter_partial(filter[:query], field_searched, filter[:label])
      end
    end
  end

  # Generate the label for the filter
  def generate_filter_label(field, datasource, filter_or_search, later_or_earlier="")
    # Get the fields to generate the title
    if datasource
      dataspec = get_dataspecs_for_project(ENV["PROJECT_INDEX"]).select{|spec| spec["class_name"].underscore==datasource}[0]
      fields_list = dataspec["source_fields"]
      source_name = " (#{dataspec["name"]})"
    else # Is a facet, check full facet list
      fields_list = get_facets_for_project(ENV["PROJECT_INDEX"])
    end

    # Get the human readable title and return the label
    human_readable = human_readable_title(fields_list[field])
    return "#{human_readable}#{later_or_earlier}#{source_name.to_s} [#{filter_or_search}]"
  end

  # Filter info hash
  def generate_filter_info_hash(query, label)
    [{query: query, label: label}]
  end

  # Render the filter partial
  def render_filter_partial(query, field_searched, label)
    render partial: "search/search_filters/filter", locals: { query: query,
                                                              field_searched: field_searched,
                                                              label: label}
  end

  
  # Show filters for facet vals
  def render_facet_filters(field_searched, query)
    query_array = query.is_a?(Array) ? query : [query]
    
    return query_array.inject([]) do |queries, filter_query|
      label = generate_filter_label(field_searched.gsub("_facet", ""), nil, "filter", nil)
      queries.push({query: filter_query, label: label})
    end
  end

  # Show filters for date vals
  def generate_date_filter(field_searched, query)
    field, datasource = field_searched.gsub("startrange_", "").gsub("endrange_", "").split("_source_")
    later_or_earlier = field_searched.include?("startrange_") ? " Later Than" : " Earlier Than"
    label = generate_filter_label(field, datasource, "search", later_or_earlier)
    return generate_filter_info_hash(query, label)
  end

  # Render filters for normal search queries
  def generate_search_filter(field_searched, query)
    field, datasource = field_searched.split("_source_")
    label = generate_filter_label(field, datasource, query, "search")
    return generate_filter_info_hash(query, label)
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
    return params.except(*@params_to_ignore).length <= 1 &&
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
