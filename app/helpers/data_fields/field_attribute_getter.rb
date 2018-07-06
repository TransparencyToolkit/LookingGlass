# Gets attribute values for fields, used by many display funcs
module FieldAttributeGetter
  # Check if there is data in a given field
  def data_for_field_type?(dataspec, doc, type)
    fields = dataspec["source_fields"].select{|field, details| details["display_type"] == type }.keys
    data_for_field = fields.inject([]){|data, field| data.push(doc["_source"][field]) }
    return !data_for_field.compact.reject{|c| c.empty?}.empty?
  end
  
  # Gets text for the field
  def get_text(doc, field, field_details)
    if is_highlighted?(doc, field)
      return raw(doc["highlight"][field].first.to_s)
    else
      return prepend_prefix(field_value(doc, field), field_details)
    end
  end

  # Replaces newlines with br
  def format_text(text)
    sanitize_text(raw(text).gsub("\n", "<br />"))
  end

  # Sanitize the text
  def sanitize_text(text)
    return sanitize(text, tags: ['br', 'b', 'li', 'ul', 'ol', 'a', 'strong', 'i', 'p', 'img', 'href'])
  end

  # Prepend the prefix (for attachments or images)
  def prepend_prefix(value, field_details)
    # Handle prefixes for array and string values
    if field_details["prefix"] && !value.blank?
      value.is_a?(Array) ? (return value.map{|val| field_details["prefix"]+val}) : (return field_details["prefix"]+value) 
    else # Don't add prefix if none specified
      return value
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
    field_details["icon"].to_s
  end

  # Get the dataspec for a specified source in project
  def get_spec_for_source(datasource)
    get_dataspecs_for_project(ENV["PROJECT_INDEX"]).select{|spec| spec["class_name"].underscore==datasource}[0]
  end

  # Get the human readable name for the data source
  def datasource_name(datasource)
    get_spec_for_source(datasource)["name"]
  end

  # Gets the name when just given a field and datasource
  def get_human_readable_name_for_field(field, source)
    # Gets the fields list from the spec for facets or one source
    if source == "facets"
      fields_list = get_facets_for_project(ENV["PROJECT_INDEX"])
    else
      fields_list = get_spec_for_source(source)["source_fields"]
    end
    
    human_readable_title(fields_list[field])
  end
end
