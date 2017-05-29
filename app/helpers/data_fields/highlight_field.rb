# Methods for managing highlighted fields
module HighlightField
  # Checks if field is highlighted in restuls
  def is_highlighted?(doc, field)
    return doc["highlight"] && doc["highlight"][field] && !doc["highlight"][field].empty?
  end

  # Gets list of the highlighted categories
  def get_highlighted_categories(doc, fieldname)
    highlightlist = Hash.new

    if is_highlighted?(doc, fieldname)
      doc["highlight"][fieldname].each do |field|
        highlightlist[ActionView::Base.full_sanitizer.sanitize(field)] = field
      end
    end

    return highlightlist
  end

  # Bold the text if it is highlighted
  def highlighted_facet_text(item_val, doc, field)
    # Get a list of highlighted facets
    highlighted_categories = get_highlighted_categories(doc, field)

    # Bold text if highlighted
    highlighted_categories[item_val] ? raw(highlighted_categories[item_val]) : item_val.to_s.strip
  end
end
