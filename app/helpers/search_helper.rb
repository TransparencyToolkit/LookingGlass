module SearchHelper
  # Get all searchable fields
  def matchFieldTypes(match_type, source)
    outhtml = ""
    
    # Get only fields matching type
    matching_fields = source["source_fields"].select{|k,v| match_type.include?(v["display_type"])}

    # Go through matching fields
    matching_fields.each do |field|
      outhtml += genOptionHtml(field, source["class_name"].underscore)
    end

    return outhtml
  end

  # Group by dataset
  def gen_searchbar_fields_list
    datasources = get_dataspecs_for_project(ENV['PROJECT_INDEX'])

    render partial: "docs/queries/dropdown/dropdown", locals: { datasources: datasources }
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
  def genOptionHtml(field, source_name)
    render partial: "docs/queries/dropdown/dropdown_field_option", locals: {display_type: field[1]["display_type"],
                                                               human_readable_name: field[1]["human_readable"],
                                                               field_param: field[0]+"_source_"+source_name
                                                              }
  end
end
