module SearchHelper
  # Get all searchable fields
  def matchFieldTypes(match_type, source, field_type)
    outhtml = ""
    
    # Get only fields matching type
    matching_fields = source["source_fields"].select{|k,v| match_type.include?(v["display_type"])}

    # Go through matching fields
    matching_fields.each do |field|
      outhtml += genOptionHtml(field, source["class_name"].underscore, field_type)
    end

    return outhtml
  end

  # Groups fields by type
  def group_and_render(source)
    render partial: "docs/queries/dropdown/dropdown_source_options", locals: {
             source_param_name: "all_source_"+source["class_name"].underscore,
             source_hr_name: source["name"],
             source: source
           }
  end

  # Generate html for the matching option
  def genOptionHtml(field, source_name, field_type)
    render partial: "docs/queries/dropdown/dropdown_field_option", locals: {field_type: field_type,
                                                               human_readable_name: field[1]["human_readable"],
                                                               field_param: field[0]+"_source_"+source_name,
                                                               field: field
                                                              }
  end
end
