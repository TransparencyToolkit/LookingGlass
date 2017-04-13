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
