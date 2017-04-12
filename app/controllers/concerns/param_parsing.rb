module ParamParsing
  # Calculate start and page num from URL params
  def page_calc(params)
    # Set page number from params
    pagenum = params[:page] ? params[:page].to_i : 1

    # Calculate start index for docs
    start = pagenum*30-30
    return pagenum, start
  end

  # Parse params for facet
  def parse_facet_params
    # Get just the params that are facets
    facet_params = params.select{|k, v| k.include?("_facet")}

    # Remap the params
    return facet_params.inject([]) do |remapped, facet|
      # Handle all facets as arrays
      value_list = facet[1].is_a?(Array) ? facet[1] : [facet[1]]
      facet_name = facet[0].gsub("_facet", ".keyword")

      # Save param for each
      value_list.each{|facet_val| remapped.push({facet_name => facet_val})}
      remapped
    end.to_json
  end
end
