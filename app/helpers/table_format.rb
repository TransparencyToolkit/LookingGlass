module TableFormat
  # Checks if field is highlighted in restuls
  def isHighlighted?(doc, field)
    return doc["highlight"] && doc["highlight"][field] && !doc["highlight"][field].empty?
  end

  # Gets text for the field (highlighted if it should be)
  def getText(doc, field)
    if isHighlighted?(doc, field)
      return raw(doc["highlight"][field].first.to_s)
    else
      # Handles both with _source and without
      begin
        return doc["_source"][field]
      rescue
        return doc[field]
      end
    end
  end

  # Generates links to data filtered by facet val
  def linkedFacets(field_vals, field_name)
    outstr = ""

    # Generate links for each value in list of facet vals
    if field_vals.is_a?(Array)
      field_vals.each do |i|
        outstr += link_to(i.strip, search_path((field_name+"_facet").to_sym => i))
        outstr += ", " if i != field_vals.last
      end
    # For single values
    else
      if field_vals 
        outstr += link_to(field_vals.strip, search_path((field_name+"_facet").to_sym => field_vals))
      end
    end
    return outstr
  end

  # Get list of items in results and their names
  def tableItems
    itemarr = Array.new

    # Get list of all fields in results
    sortFields(@fields_in_results).each do |i|
      # Get details (HR name, field name, etc) for field
      itemarr.push(getFieldDetails(i))
    end

    return itemarr
  end
end
