module TableFormat
  # Checks if field is highlighted in restuls
  def isHighlighted?(nsadoc, field)
    return nsadoc["highlight"] && nsadoc["highlight"][field] && !nsadoc["highlight"][field].empty?
  end

  # Gets text for the field (highlighted if it should be)
  def getText(nsadoc, field)
    if isHighlighted?(nsadoc, field)
      return raw(nsadoc["highlight"][field].first.to_s)
    else
      return nsadoc["_source"][field]
    end
  end

  # Generates links to data filtered by facet val   
  def linkedFacets(field_vals, field_name)
    outstr = ""

    if field_vals.is_a?(Array)
      # Generate links for each value in list of facet vals                                        
      field_vals.each do |i|
        outstr += link_to(i, search_path((field_name+"_facet").to_sym => i))
        outstr += ", " if i != field_vals.last
      end
    else # For single values
      outstr += link_to(field_vals, search_path((field_name+"_facet").to_sym => field_vals))
    end
    return outstr
  end

  # Get list of items in table and their names
  def tableItems
    itemarr = Array.new

    @field_info_sorted.each do |i|
      if i["In Table?"] == "Yes"
        itemarr.push(i)
      end
    end

    return itemarr
  end
end
