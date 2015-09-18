module QueryFormat
  include GeneralUtils

  # Get all searchable fields
  def matchFieldTypes(match_type, dataspec)
    outhtml = ""
    
    # Go through all searchable fields
    sortFields(dataspec.searchable_fields, dataspec.field_info).each do |field|
      f = getFieldDetails(field, dataspec.field_info)

      # If display type matches, add html
      if match_type.include?(f["Display Type"])
        outhtml += genOptionHtml(f, dataspec.index_name)
      end
    end

    return outhtml
  end

  # Group by dataset
  def group_by_dataset
    # Gen form
    outhtml = '<form action="" class="navbar-form navbar-left input-group-addon">                                                    
     <select name="ftypes" id="ftypes">'
    outhtml += '<option data-type="all" value="all" selected>All</option>'
    
    # Gen search form (all for all datasets)
    run_all do |dataspec, model|
      outhtml = outhtml + '<optgroup label="'+dataspec.dataset_name+'">'
      outhtml += group_by_type(dataspec)
      outhtml += '</optgroup>'
    end
    outhtml += '</select></form>'
    return outhtml
  end

  # Groups fields by type
  def group_by_type(dataspec)
    outhtml = '<option data-type="all" value="all_sindex_'+dataspec.index_name+'">'+'All '+dataspec.dataset_name+'</option>'
    outhtml = outhtml + '<optgroup label="Text">'+
              raw(matchFieldTypes(["Title", "Description", "Short Text", "Medium Text", "Long Text"], dataspec)) + '</optgroup>'
    outhtml = outhtml + '<optgroup label="Date">'+ raw(matchFieldTypes(["Date"], dataspec))+ '</optgroup>'
    outhtml = outhtml + '<optgroup label="Categories">'+raw(matchFieldTypes(["Category"], dataspec))+'</optgroup>'
  end
  
  # Generate html for the matching option
  def genOptionHtml(f, index)
    return '<option data-type="' + f["Type"] +
           '"  value="' + f["Field Name"] + '_sindex_'+index+'">' + f["Human Readable Name"] + '</option>'
  end
end
