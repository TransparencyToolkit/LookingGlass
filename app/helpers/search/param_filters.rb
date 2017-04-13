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
        filters = generate_facet_filters(field_searched, query)
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
  def generate_filter_label(field, filter_or_search, datasource="facets", later_or_earlier="")
    # Get the human readable title
    source_name = " (#{datasource_name(datasource)})" if datasource != "facets"
    human_readable = get_human_readable_name_for_field(field, datasource)

    # Generates and returns the label
    return "#{human_readable}#{later_or_earlier}#{source_name.to_s} [#{filter_or_search}]"
  end

  # Filter info hash
  def generate_filter_info_hash(query, label)
    [{query: query, label: label}]
  end

  # Render the filter partial
  def render_filter_partial(query, field_searched, label)
    render partial: "docs/index/search/param_filters/filter", locals: { query: query,
                                                              field_searched: field_searched,
                                                              label: label}
  end

  
  # Show filters for facet vals
  def generate_facet_filters(field_searched, query)
    query_array = query.is_a?(Array) ? query : [query]
    
    return query_array.inject([]) do |queries, filter_query|
      label = generate_filter_label(field_searched.gsub("_facet", ""), "filter")
      queries.push({query: filter_query, label: label})
    end
  end

  # Show filters for date vals
  def generate_date_filter(field_searched, query)
    field, datasource = field_searched.gsub("startrange_", "").gsub("endrange_", "").split("_source_")
    later_or_earlier = field_searched.include?("startrange_") ? " Later Than" : " Earlier Than"
    label = generate_filter_label(field, "search", datasource, later_or_earlier)
    return generate_filter_info_hash(query, label)
  end

  # Render filters for normal search queries
  def generate_search_filter(field_searched, query)
    field, datasource = field_searched.split("_source_")
    label = generate_filter_label(field, "search", datasource)
    return generate_filter_info_hash(query, label)
  end
end
