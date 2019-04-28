module FacetSidebar
  # Get the list of facets for the sidebar
  def get_facet_list_for_sidebar
    return get_facet_list_divided_by_source(ENV['PROJECT_INDEX'])
  end

  # Load the variables for a specific facet field
  def load_vars_for_facet_tree(field, facets)
    @aggregation = facets[field[0]]
    @hr_name = human_readable_title(field[1])
    @icon = icon_name(field[1])
    @bucket_count = @aggregation["buckets"].length.to_s

    # Add classes to facet tree
    if field[1]["expand_by_default"] != "true"
      @label_class = "tree-toggler just-plus"
      @list_class = "collapse"
    end
  end

  # Check if the category is empty for the query
  def category_empty_for_query?(field, facets)
    return facets[field[0]]["buckets"].length == 0
  end

  # Only display title if there are facet fields and vals, and if it isn't overall set
  def display_title?(fields, facets, source, facet_list)
    field_count_for_source = fields.to_a.select{|field| !category_empty_for_query?(field, @facets)}.length
    return !(fields.blank? || source == "overall" || field_count_for_source == 0 || facet_list.except("overall").keys.length < 2)
  end
end
