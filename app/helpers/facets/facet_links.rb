# Generates links for facet queries and views
module FacetLinks
  # Just add facet: Generate search path for link with single facet
  def gen_basic_search_path(field_name, facet_val)
    search_path(field_name.to_sym => facet_val)
  end

  # Merge with existing params: New search path for facet (to avoid pagination issue)
  def gen_merged_search_path(params, category_name, chosen)
    search_params = params.symbolize_keys.merge(category_name.to_sym => chosen, :page => 1)
    return search_path(search_params)
  end

  # Generate facet name
  def gen_facet_link_name(val)
    return "#{val["key"]} (#{val["doc_count"].to_s})"
  end

  # Generate a single facet link
  def gen_facet_link(link_text, path)
    link_to(link_text, path)
  end

  
  # Generates a list of links to display in results template
  def facet_links_for_results(doc, field_name, facet_vals)
    # Convert to an array if not already an array
    facet_vals = [facet_vals] if !facet_vals.is_a?(Array)

    # Generate list of field links
    return facet_vals.reject(&:blank?).map do |item|
      link_text = highlighted_facet_text(item, field_name, doc)
      gen_facet_link(link_text, gen_basic_search_path(field_name, item))
    end.join(", ")
  end

  
  # Generate link html for single term
  def termLink(val, categories_chosen, category_name)
    # Facet link should be removed from query if selected
    if is_selected?(categories_chosen, val)
      return remove_facet_from_query_params(val, categories_chosen, category_name)
    else # Facet link should be added to query
      return add_facet_to_query_params(val, categories_chosen, category_name)
    end
  end

  # Check if facet link is being generated for is selected
  def is_selected?(categories_chosen, val)
    single_match = categories_chosen == val["key"]
    multiple_match = (categories_chosen.is_a?(Array) && categories_chosen.include?(val["key"]))
    return single_match || multiple_match
  end
  

  # Add facet to the query
  def add_facet_to_query_params(val, categories_chosen, category_name)
    if categories_chosen # Check if another facet in the same category is selected
      return add_another_facet_in_category(categories_chosen, val, category_name)
    else
      return add_first_facet_in_category(val, category_name)
    end
  end

  # Add facets: Add first facet for category to query
  def add_first_facet_in_category(val, category_name)
    val_link = gen_facet_link(gen_facet_link_name(val), gen_merged_search_path(params, category_name, val["key"]))
    params.except(category_name)

    return val_link
  end

  # Add facets: Add another facet to the same category for link
  def add_another_facet_in_category(categories_chosen, val, category_name)
    # Handle multiple categories chosen vs one
    if categories_chosen.is_a?(Array)
      categories_chosen = categories_chosen.dup.push(val["key"])
    else
      categories_chosen = [categories_chosen, val["key"]]
    end

    # Generate link
    val_link = gen_facet_link(gen_facet_link_name(val), gen_merged_search_path(params, category_name, categories_chosen))
    params.except(category_name).merge(category_name => categories_chosen)

    return val_link
  end

  

  # Generate link for selected facet
  def remove_facet_from_query_params(val, categories_chosen, category_name)
    # Case 1 and 2: Params other than facet to remove
    if other_queries_already_selected?(category_name, categories_chosen)
      return remove_without_removing_other_params(val, categories_chosen, category_name)
    else # Case 3: No other params left
      return gen_facet_link(gen_facet_link_name(val), root_path)
    end
  end

  # Check if any other facets are selected
  def other_queries_already_selected?(facet_category, facets_chosen)
    return params.except("controller", "action", "utf8", "page", "a", "c", facet_category).length > 0 || facets_chosen.is_a?(Array)
  end

  # Remove facet if there are other params
  def remove_without_removing_other_params(val, categories_chosen, category_name)
    # Case 1: Other facets in same category
    if categories_chosen.is_a?(Array)
      remove_facetval_from_category_param_array(val, categories_chosen, category_name)
    else # Case 2: Other params, but not in same category
      remove_facet_but_not_other_params(category_name, val)
    end
  end

  # Case 1: Remove facet filter without removing others in same category
  def remove_facetval_from_category_param_array(val, categories_chosen, category_name)
    outval = categories_chosen.dup
    outval.delete(val["key"])
    outval = outval[0] if categories_chosen.count <= 2
    return gen_facet_link(gen_facet_link_name(val), gen_merged_search_path(params.except(category_name), category_name, outval))
  end

  # Remove facet but not the other params
  def remove_facet_but_not_other_params(category_name, val)
    search_params = params.symbolize_keys.except(category_name.to_sym, :page)
    return gen_facet_link(gen_facet_link_name(val), search_path(search_params))
  end
end
