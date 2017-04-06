# Gets  attribute values for fields, used by many display funcs
module FieldAttributeGetter
  # Gets text for the field
  def get_text(doc, field)
    if is_highlighted?(doc, field)
      return raw(doc["highlight"][field].first.to_s)
    else
      return field_value(doc, field)
    end
  end

  # Get the value for the field in the doc
  def field_value(doc, field)
    doc["_source"][field]
  end

  # Get the human readable title for the field
  def human_readable_title(field_details)
    field_details["human_readable"]
  end

  # Get the name of the icon
  def icon_name(field_details)
    field_details["Icon"].to_s
  end
end
