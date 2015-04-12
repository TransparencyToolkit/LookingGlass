module TableFormat
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
