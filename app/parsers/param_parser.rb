module ParamParser
  include GeneralUtils

  # Processes parameters for search query generation             
  def process_params
    processed_params = Hash.new
    model_to_search = nil

    if @params[:q] then processed_params = {field: "_all", searchterm: @params[:q]} # Search all fields     
    else # For searching individual fields
      # Get correct dataspec and item
      param_item, dataspec = get_search_param(@params)

      # Get params and model to search
      processed_params, model_to_search = find_field_param_match(param_item, dataspec)
    end

    processed_params == {} if processed_params.empty?
    return processed_params, model_to_search
  end

  # Finds params that match for a given dataspec
  def find_field_param_match(param_item, dataspec)
    dataspec.searchable_fields.each do |field|
      # Find field that matches in dataspec and process
      if paramMatch?(getFieldDetails(field, dataspec.field_info), param_item)
        return process_param_by_type(field, dataspec)
      end
    end
  end

  # Gets name that would show up in params
  def unprocess_item_name(search_item, dataspec)
    return (search_item.to_s+"_sindex_"+dataspec.index_name).to_sym
  end


  # Split each field into field name and search terms for query processing        
  def process_param_by_type(search_item, dataspec)
    # Get field details and name to search
    item_info = getFieldDetails(search_item, dataspec.field_info)
    fieldname = dataspec.facet_fields.include?(search_item) ? (search_item+"_analyzed").to_sym : search_item.to_sym

    # Check if it is a date and handle input differently if so      
    if item_info["Type"] == "Date"
      processed_params = process_date_params(fieldname, item_info)

    # If not a date                                                              
    else
      processed_params = {
        field: fieldname,
        searchterm: @params[unprocess_item_name(search_item, dataspec)]
      }
    end
    
    # Return params and model to search
    return processed_params, get_model(dataspec.index_name)
  end
end
