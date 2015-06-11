module DocFormat
  # Replaces newlines with br
  def format_text(text)
    text.gsub("\n", "<br />")
  end

  # Sorts item field by creation date
  def item_field_sort(items, sort_field)
    return sorted = items.sort do |b, a|
      a[sort_field] && b[sort_field] ? a[sort_field] <=> b[sort_field] : a[sort_field] ? -1 : 1
    end
  end

  # Generate a link
  def prepareLink(this_url)
    return link_to this_url, this_url, target: "_blank"
  end

  # Wraps field name in tags and gets doc text for showing in doc   
  def prepareField(field, doc)
    outstr = ''
    if field["Display Type"] == "Picture"
      outstr += image_tag(doc[field["Field Name"]], :class => "picture")
    else
      outstr += '<strong>'+field["Human Readable Name"]+': </strong>'
      if checkIfX(field, @truncated_fields)
        outstr += raw format_text(doc[field["Field Name"]]) if doc[field["Field Name"]]
      elsif field["Display Type"] == "Link"
        # Handle single and arrays of links
        if doc[field["Field Name"]].is_a?(Array)
          doc[field["Field Name"]].each do |u|
            outstr = outstr + prepareLink(u.to_s) + '<br />'
          end
        else
          outstr += prepareLink(doc[field["Field Name"]].to_s)
        end
        return outstr
      else
        outstr += doc[field["Field Name"]].to_s
      end
    end
  end
end
