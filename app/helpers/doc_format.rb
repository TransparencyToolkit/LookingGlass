module DocFormat
  include TableFormat

  # Prints the fields in the sidebar or text
  def printData(doc, print_conditions, print_type, dataspec, fields)
    output = ''

    # Go through sorted list
    sortFields(fields, dataspec.field_info).each do |field|
      f = getFieldDetails(field, dataspec.field_info) # Full field details

      # Print if field it fulfills conditions
      if print_conditions.call(f, doc)
        case print_type
        when "fields"
          output += printFields(f, doc).to_s
        when "sidebar"
          output += printSidebarItem(f, doc).to_s
        end
      end
    end

    return output
  end

  # Prints the field name and content if filled in
  def printFields(f, doc_content)
    field_content = doc_content[f["Field Name"]]
    if field_content != nil && !field_content.to_s.empty? && field_content != "[]"
      return "<p class=#{f["Field Name"]}>"+raw(prepareField(f, doc_content))+'</p>'
    end
  end

  # Prints the sidebar item
  def printSidebarItem(f, doc)
    if !doc[f["Field Name"]].empty?
      return '<p>'+prepareIcon(f)+prepareFieldName(f)+linkedFacets(doc[f["Field Name"]], f["Field Name"], {})+'</p>'
    end
  end

  # Gets the first doc in list, useful for getting item fields
  def getFirstDoc
    return @link_type["Link Type"] == "mult_items" ? @docs.first["_source"] : @doc
  end

  # Prepare to print icon
  def prepareIcon(f)
    return image_tag(f["Icon"]+"-24.png")+' '
  end

  # Replaces newlines with br
  def format_text(text)
    text.gsub("\n", "<br />")
  end

  # Sorts item field by creation date
  def item_field_sort(items, sort_field)
    return sorted = items.sort do |b, a|
      gf(a, sort_field) && gf(b, sort_field) ? gf(a, sort_field) <=> gf(b, sort_field) : gf(a, sort_field) ? -1 : 1
    end
  end

  # Gets the field with _source
  def gf(item, field)
    return item["_source"][field]
  end

  # Generate a link
  def prepareLink(this_url)
    return link_to this_url, this_url, target: "_blank"
  end

  # Prepare a picture field
  def preparePictureFields(doc, field)
    return image_tag(doc[field["Field Name"]], :class => "picture")
  end

  # Format field names
  def prepareFieldName(field)
    return '<strong class="label">'+field["Human Readable Name"]+': </strong>'
  end

  # Format longer text fields
  def prepareLongText(doc, field)
    return raw(format_text(doc[field["Field Name"]])) if doc[field["Field Name"]]
  end

  # Handles both single links and arrays of links
  def handleLinkFields(doc, field)
    # Get link field content
    links = doc[field["Field Name"]]
    outstr = ''

    # Handle multiple links
    if links.is_a?(Array)
      links.each do |u|
        outstr = outstr + prepareLink(u.to_s) + '<br />'
      end
    else # Handle single links
      outstr += prepareLink(links.to_s)
    end

    return outstr
  end

  # Wraps field name in tags and gets doc text for showing in doc
  def prepareField(field, doc)
    outstr = ''

    # Handle picture fields
    if field["Display Type"] == "Picture"
      outstr += preparePictureFields(doc, field)
    else # Handle fields that need a field name first
      outstr += prepareTextFields(doc, field)
    end
  end

  # Handles text fields that need a field name first
  def prepareTextFields(doc, field)
    outstr = prepareFieldName(field)

    # Long text
    if checkIfX(field, @truncated_fields)
      outstr += prepareLongText(doc, field)

    # Links
    elsif field["Display Type"] == "Link"
      outstr += handleLinkFields(doc, field)

    else # Any other text
      outstr += doc[field["Field Name"]].to_s
    end

    return outstr
  end
end
