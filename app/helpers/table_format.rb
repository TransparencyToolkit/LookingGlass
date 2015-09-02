module TableFormat
  # Checks if field is highlighted in restuls
  def isHighlighted?(doc, field)
    return doc["highlight"] && doc["highlight"][field] && !doc["highlight"][field].empty?
  end

  # Gets text for the field (highlighted if it should be)
  def getText(doc, field, full_doc)
    if isHighlighted?(full_doc, field)
      return raw(full_doc["highlight"][field].first.to_s)
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
        outstr += facetLinkGen(i, field_name)
        outstr += ", " if i != field_vals.last
      end
    # For single values
    else
      if field_vals
        outstr += facetLinkGen(field_vals, field_name)
      end
    end
    return outstr
  end

  # Generate facet link for category results
  def facetLinkGen(field_vals, field_name)
    return link_to(field_vals.strip, search_path((field_name+"_facet").to_sym => field_vals))
  end

  # Display the item in the appropriate way for the display type
  def showByType(display_type, doc, full_doc, is_item_field)
    output = ""
    
    tableItems.each do |t|
      # Get fields of appropriate display and item field type
      if (t["Display Type"] == display_type) && (is_item_field == @item_fields.include?(t["Field Name"]))
        # Get processed value
        processed_value = processType(t, display_type, doc, full_doc)

        # Add to output if it is not nil or a category type
        if doc[t["Field Name"]] != nil # Check if nil first
          output += processed_value if (processed_value != nil) && (!doc[t["Field Name"]].empty?)
        end
      end
    end

    return raw(output)
  end

  # Processes type appropriately using case statement
  def processType(t, display_type, doc, full_doc)
    case display_type
    when "Title"
      return titleView(t, doc, full_doc)
    when "Short Text", "Description"
      return shortTextView(t, doc, full_doc)
    when "Date"
      return dateView(t, doc)
    when "Long Text"
      return longTextView(t, doc, full_doc)
    when "Picture"
      return pictureView(t, doc)
    when "Category"
      return categoryView(t, doc)
    end
  end

  # Prepares picture view
  def pictureView(t, doc)
    return image_tag(doc[t["Field Name"]], :class => "picture")
  end
  
  # Prepares date view
  def dateView(t, doc)
    return '<span class="date">'+ t["Human Readable Name"]+ ': <span class="list_date">'+doc[t["Field Name"]]+'</span></span>'
  end
  
  # Prepares title view
  def titleView(t, doc, full_doc)
    return link_to(getText(doc, t["Field Name"], full_doc), doc_path(full_doc["_id"]), class: "list_title", target: "_blank")
  end

  # Prepares description/short text view
  def shortTextView(t, doc, full_doc)
      return getText(doc, t["Field Name"], full_doc)
  end

  # Prepares longer text view
  def longTextView(t, doc, full_doc)
    return truncate(getText(doc, "doc_text", full_doc), length: 200)
  end

  # Prepares facet view
  def categoryView(t, doc)
    
    output = ''
    
    if @facet_fields.include?(t["Field Name"])
      facet_links = linkedFacets(doc[t["Field Name"]], t["Field Name"])
      
      if facet_links != "" && !facet_links.empty?
        output += facetPrepare(t, facet_links)
      end
    end

    return output
  end

  # Format and return the facet
  def facetPrepare(t, facet_links)
    return '<div class="facet'+ t["Field Name"] +'">'+ image_tag(t["Icon"]+"-24.png") + facet_links +' </div>'
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
