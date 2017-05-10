# Generates a link without the filter for the corresponding facet.
# Used in sidebar AND for param filters near topbar.
# Covers following cases-
# 1. Other facets in same category: Remove term from array, but not category from params
# 2. Only facet in category, other params: Remove category from params
# 3. Only param: Link to root path


module RemoveFacetFilter
  # Generate link for selected facet
  def remove_from_query_params(link_val, vals_chosen, category_field, remove_filter=false)
    # Case 1 and 2: Params other than facet to remove
    if other_queries_in_params?(category_field, vals_chosen)
      path = remove_without_removing_other_params(link_val, vals_chosen, category_field)
    else # Case 3: No other params left
      path = root_path
    end

    return gen_link_with_query_removed(path, link_val, remove_filter)
  end

  # Generates a link with the query removed
  def gen_link_with_query_removed(path, link_val, remove_filter)
    if remove_filter
      return gen_facet_link('X', path, false, "remove-filter")
    else
      return gen_facet_link(gen_facet_link_name(link_val), path, true)
    end
  end

  # Check if any other facets are selected
  def other_queries_in_params?(category_field, vals_chosen)
    ignore_these_params = @params_to_ignore+[category_field]
    return params.except(*ignore_these_params).length > 0 || vals_chosen.is_a?(Array)
  end

  # Case 1 and 2: Remove facet if there are other params
  def remove_without_removing_other_params(link_val, vals_chosen, category_field)
    # Case 1: Other facets in same category
    if vals_chosen.is_a?(Array)
      return remove_facetval_from_category_param_array(link_val, vals_chosen, category_field)
    else # Case 2: Other params, but not in same category
      return remove_facet_but_not_other_params(category_field, link_val)
    end
  end

  # Case 1: Remove facet filter without removing others in same category
  def remove_facetval_from_category_param_array(link_val, vals_chosen, category_field)
    outval = vals_chosen.dup
    link_val.is_a?(Hash) ? outval.delete(link_val["key"]) : outval.delete(link_val)
    outval = outval[0] if vals_chosen.count <= 2
    return gen_merged_search_path(params.except(category_field), category_field, outval)
  end

  # Case 2: Remove facet but not the other params
  def remove_facet_but_not_other_params(category_field, link_val)
    search_params = params.symbolize_keys.except(category_field.to_sym, :page)
    return search_path(search_params)
  end
end 
