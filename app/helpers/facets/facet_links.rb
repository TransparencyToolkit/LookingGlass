# Generates links for facet queries and views
module FacetLinks
  # Generate a single facet link
  def gen_facet_link(field_name, facet_val, link_text)
    link_to(link_text, search_path(field_name.to_sym => facet_val))
  end

  # Generates a list of links to display in results template
  def list_of_facet_links(doc, field_name, facet_vals)
    # Convert to an array if not already an array
    facet_vals = [facet_vals] if !facet_vals.is_a?(Array)

    # Generate list of field links
    return facet_vals.reject(&:blank?).map do |item|
      link_text = highlighted_facet_text(item, field_name, doc)
      gen_facet_link(field_name, link_text, item)
    end.join(", ")
  end
end
