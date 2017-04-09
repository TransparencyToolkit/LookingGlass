module DropdownFormGen
  # Get all searchable fields
  def load_field_options_for_type(match_type, source, field_type)
    # Get only fields matching type
    matching_fields = source["source_fields"].select{|k,v| match_type.include?(v["display_type"])}

    # Go through matching fields
    return matching_fields.inject("") do |html, field|
      html += render_field_option_html(field, source["class_name"].underscore, field_type)
    end
  end

  # Generate param name for the source
  def gen_source_param_name(source)
    return "all_source_"+source["class_name"].underscore
  end

  # Generate html for the field option for dropdown
  def render_field_option_html(field, source_name, field_type)
    render partial: "docs/queries/dropdown/dropdown_field_option", locals: {field_type: field_type,
                                                                            human_readable_name: field[1]["human_readable"],
                                                                            field_param: field[0]+"_source_"+source_name,
                                                                           }
  end
end
