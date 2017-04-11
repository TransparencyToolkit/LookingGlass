# Generates links for facet queries and views
module FacetLinks
  # Add facet to field name
  def facetize_field(name)
    "#{name}_facet".to_sym
  end
  
  # Just add facet: Generate search path for link with single facet
  def gen_basic_search_path(field_name, facet_val)
    search_path(field_name => facet_val)
  end

  # Merge with existing params: New search path for facet (to avoid pagination issue)
  def gen_merged_search_path(params, category_field, chosen)
    search_params = params.symbolize_keys.merge(category_field => chosen, :page => 1)
    return search_path(search_params)
  end

  # For modifying arrays of params: Generate a link that replaces the value of a param with a different val (for same param)
  def replace_param_val_in_facet_link(link_val, category_field, vals_chosen)
    gen_facet_link(gen_facet_link_name(link_val), gen_merged_search_path(params.except(category_field), category_field, vals_chosen))
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
      gen_facet_link(link_text, gen_basic_search_path(facetize_field(field_name), item))
    end.join(", ")
  end

  
  # Generate link html for sidebar and filters
  def gen_facet_link_with_params(link_val, vals_chosen, category_field)
    # Facet link should be removed from query if selected
    if is_selected?(vals_chosen, link_val)
      return remove_facet_from_query_params(link_val, vals_chosen, facetize_field(category_field))
    else # Facet link should be added to query
      return add_facet_to_query_params(link_val, vals_chosen, facetize_field(category_field))
    end
  end

  # Check if facet val is already selected
  def is_selected?(vals_chosen, link_val)
    single_match = vals_chosen == link_val["key"]
    multiple_match = (vals_chosen.is_a?(Array) && vals_chosen.include?(link_val["key"]))
    return single_match || multiple_match
  end
end
