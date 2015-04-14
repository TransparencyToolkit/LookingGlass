module ParamParser
  # Processes parameters for search query generation                                         
  def process_params
    processed_params = Hash.new

    if @params[:q] then processed_params = {field: "_all", searchterm: @params[:q]} # Search all fields     
    else # For searching individual fields 
      @field_info.each do |f|
        if f["Searchable?"] == "Yes"
          if @params.include?(f["Form Params"]) || @params.include?(f["Form Params"][0]) || @params.include?(f["Form Params"][1])
            processed_params = process_param_by_type(f)
            break
          end
        end
      end
    end

    processed_params == {} if processed_params.empty?
    return processed_params
  end


  # Split each field into field name and search terms for query processing        
  def process_param_by_type(search_item)
    fieldname = search_item["Facet?"] == "Yes" ? (search_item["Field Name"]+"_analyzed").to_sym : search_item["Field Name"].to_sym

    # Check if it is a date and handle input differently if so      
    if search_item["Type"] == "Date"
      processed_params = process_date_params(fieldname, search_item)

    # If not a date                                                                                                 
    else
      processed_params = {
        field: fieldname,
        searchterm: @params[search_item["Field Name"]]
      }
    end

    return processed_params
  end
end
