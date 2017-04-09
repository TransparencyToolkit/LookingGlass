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
    # Gen form
    outhtml = '<form action="" class="navbar-form navbar-left input-group-addon">
     <select name="ftypes" id="ftypes" class="form-control">'
    outhtml += '<option data-type="all" value="all" selected>All</option>'

    datasources = get_dataspecs_for_project(ENV['PROJECT_INDEX'])

    # Gen search form (all for all datasets)
    datasources.each do |source|
      outhtml = outhtml + '<optgroup label="'+source["name"]+'">'
      outhtml += group_by_type(source)
      outhtml += '</optgroup>'
    end
    outhtml += '</select></form>'
    return outhtml
  end

  # Groups fields by type
  def group_by_type(source)
    outhtml = '<option data-type="all" value="all_source_'+source["class_name"].underscore+'">'+'All '+source["name"]+'</option>'
    outhtml = outhtml + '<optgroup label="Text">'+
              raw(matchFieldTypes(["Title", "Description", "Short Text", "Medium Text", "Long Text", "Tiny Text"], source)) + '</optgroup>'
    outhtml = outhtml + '<optgroup label="Date">'+ raw(matchFieldTypes(["Date"], source))+ '</optgroup>'
    outhtml = outhtml + '<optgroup label="Categories">'+raw(matchFieldTypes(["Category"], source))+'</optgroup>'
  end

  # Generate html for the matching option
  def genOptionHtml(field, source_name)
    return '<option data-type="' + field[1]["display_type"] +
           '"  value="' + field[0] + '_source_'+source_name+'">' + field[1]["human_readable"] + '</option>'
  end
end
