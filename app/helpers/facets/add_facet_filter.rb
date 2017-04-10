# This generates links to add facet filters. Specifically, these links cover the following cases-
# 1. First facet chosen for field: Should add new field param to params. Does not matter if there are other params
# 2. Already facet chosen in field: Add param to array for field

module AddFacetFilter
  # Add facet to the query
  def add_facet_to_query_params(link_val, vals_chosen, category_field)
    if vals_chosen # Check if another facet in the same category is selected
      return add_another_facet_in_category(vals_chosen, link_val, category_field)
    else
      return add_first_facet_in_category(link_val, category_field)
    end
  end

  # Case 1: First facet for category in query
  def add_first_facet_in_category(link_val, category_field)
    return gen_facet_link(gen_facet_link_name(link_val), gen_merged_search_path(params, category_field, link_val["key"]))
  end

  # Case 2: There's already one facet chosen for the category
  def add_another_facet_in_category(vals_chosen, link_val, category_field)
    # Handle multiple categories chosen vs one
    if vals_chosen.is_a?(Array)
      vals_chosen = vals_chosen.dup.push(link_val["key"])
    else
      vals_chosen = [vals_chosen, link_val["key"]]
    end

    # Generate link
    return replace_param_val_in_facet_link(link_val, category_field, vals_chosen)
  end
end
