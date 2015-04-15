module DocFormat
  # Replaces newlines with br
  def format_text(text)
    text.gsub("\n", "<br />")
  end

  # Wraps field name in tags and gets doc text for showing in doc   
  def prepareField(field, doc)
    outstr = '<p><strong>'+field["Human Readable Name"]+': </strong>'
    if field["Truncate"] != nil
      outstr += raw format_text(doc[field["Field Name"]]) if doc[field["Field Name"]]
    else
      outstr += doc[field["Field Name"]].to_s
    end
    outstr += '</p>'
  end
end
