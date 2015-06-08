module ParamParser
  include GeneralUtils

  # Processes parameters for search query generation                           
  def process_params
    processed_params = Hash.new

    if @params[:q] then processed_params = {field: "_all", searchterm: @params[:q]} # Search all fields     
    else # For searching individual fields
      @searchable_fields.each do |field|
        if paramMatch?(getFieldDetails(field), @params)
          processed_params = process_param_by_type(field)
          break
        end
      end
    end

    processed_params == {} if processed_params.empty?
    return processed_params
  end


  # Split each field into field name and search terms for query processing        
  def process_param_by_type(search_item)
    # Get field details and name to search
    item_info = getFieldDetails(search_item)
    fieldname = @facet_fields.include?(search_item) ? (search_item+"_analyzed").to_sym : search_item.to_sym

    # Check if it is a date and handle input differently if so      
    if item_info["Type"] == "Date"
      processed_params = process_date_params(fieldname, item_info)

    # If not a date                                                              
    else
      processed_params = {
        field: fieldname,
        searchterm: @params[search_item]
      }
    end

    return processed_params
  end
end
