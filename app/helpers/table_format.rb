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

  # Display the item in the appropriate way for the display type
  def showByType(display_type, doc)
    output = ""
    
    
    tableItems.each do |t|
      # Get fields of appropriate type
      if t["Display Type"] == display_type
        # Slight variations by type
        if display_type == "Title"
          output += link_to getText(doc["_source"], t["Field Name"]), doc_path(doc["_id"]), class: "list_title", target: "_blank"
        elsif display_type == "Short Text" || display_type == "Description"
          output += getText(doc["_source"], t["Field Name"]) + '<br />'
        elsif display_type == "Date"
          output += '<span class="date">'+ t["Human Readable Name"]+ ': <span class="list_date">'+doc["_source"][t["Field Name"]]+'</span></span>'
        elsif display_type == "Long Text"
          output += truncate(getText(doc["_source"], "doc_text"), length: 200)
        elsif display_type == "Picture"
          output += image_tag(doc["_source"][t["Field Name"]], :class => "picture")
        elsif display_type == "Category"
          categoryView(t, doc)
        end
      end
    end

    return raw(output)
  end

  # Prepares facet view
  def categoryView(t, doc)
    output = ""
    if @facet_fields.include?(t["Field Name"])
      facet_links = linkedFacets(doc["_source"][t["Field Name"]], t["Field Name"])
      if facet_links != "" && !facet_links.empty?
        output += '<div class="facet'+ t["Field Name"] +'">'+ image_tag(t["Icon"]+"-24.png") + facet_links +' </div>'
      end
    end

    return output
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
