class SearchQuery
  include AllFacetsQuery

  def initialize(params, field_info)
    @params = params
    # @input = input
    @filter_by
    # @filter_by = filter_by
    @field_info = field_info
  end

  # Process search parameters
  def process_params
    queryhash = Hash.new
    if @params[:q] then queryhash = {field: "_all", searchterm: @params[:q]} # Search all fields  
    else # For searching individual fields
      @field_info.each do |f|
        if f["Searchable?"] == "Yes"
          if @params[f["Field Name"].to_sym]
            fieldname = f["Facet?"] == "Yes" ? (f["Field Name"]+"_analyzed").to_sym: f["Field Name"].to_sym

            # Check if it is a date and handle input differently if so
            if f["Type"] == "Date"
              queryhash = process_date_params

            # If not a date
            else
              searchinput = @params[f["Field Name"].to_sym]
              queryhash = {field: fieldname, searchterm: searchinput}
            end
            break
          end
        end
      end
    end

    queryhash == {} if queryhash.empty?
    return queryhash
  end

  # Process parameters for date query into form needed for build_search_query
  def process_date_params(params)
    startd = parse_date(params[f["Form Params"][0].to_sym])

    # Check if there is an end date or just a start date 
    if params[f["Form Params"]]
      params[f["Form Params"][1].to_sym].empty? ? endd = Time.now : endd = parse_date(params[f["Form Params"][1].to_sym])
    end

    return {field: fieldname, start_date: startd, end_date: endd}
  end


  # Builds the query based on input to search fields
  def build_search_query
    # If searching by date
    if get_field_type == "Date"
      queryhash = {range: { @fieldnames[0] => {gte: @input[:start_date], lte: @input[:end_date]}}}

    # If searching by any other field
    elsif @fieldnames[0] != nil
      queryhash = { bool: { should: [
                              { match: { @fieldnames[0] => {query: @input[:searchterm], type: "phrase" }}},
                              { match: { @fieldnames[0] => {query: @input[:searchterm]}}}
                            ]}}
    else
      queryhash = {}
    end
    
    return queryhash
  end

  # Date fix TODO:
  # Get query working for both release and doc
  # Add hidden fields to dates
  # Test mult, gt, lt, range

  # Gets the type of a field
  def get_field_type
    field_type = ""
    @field_info.each do |f|
      if @input[:field].to_s == f["Field Name"]
        field_type = f["Type"]
      end
    end
    return field_type
  end

  # Creates the part of the query for filtering by category
  def build_facet_filters
    hasharr = Array.new
    @filter_by.each do |k, v|
      # Handles categories where multiple values are being filtered for
      if v.is_a? Array
        v.each { |j| hasharr.push({ term: { k.gsub("_facet", "") => j}})}

      # If only one category per field is being filtered for
      else
        hasharr.push({ term: { k.gsub("_facet", "") => v}})
      end
    end
    filterhash = { "and" => hasharr }
  end

  # Combine search and facet queries based on if it is search and facets, just search, just facets
  def combine_search_and_facet_queries(queryhash, filterhash)
    if !@filter_by.empty? && !queryhash.empty?
      fullhash = { filtered: { query: queryhash, filter: filterhash }}
    elsif queryhash.empty?
      fullhash = { filtered: { filter: filterhash}}
    else
      fullhash = queryhash
    end
    return fullhash
  end

  # Figure out which fields to highlight based on which ones were searched for
  def specify_fields_to_highlight(queryhash, highlighthash)
    if !queryhash.empty? && queryhash[:bool]
      queryhash[:bool][:should][0][:match].keys.each do |k|
        if k == "_all"
          @field_info.each {|f| highlighthash[f["Field Name"]] = highlightLength(f["Field Name"])}
        else
          highlighthash[k] = highlightLength(k.to_s)
        end
      end
    end

    return highlighthash
  end
  
  def build_query
    # Initial processing of query and facet parameters
    @input = process_params                                
    @filter_by = @params.select { |i| i.include? "_facet" }
    
    @fieldnames = [@input[:field]]
    queryhash = {}
    highlighthash = Hash.new

    # Form specific query for parameters passed
    queryhash = build_search_query
    filterhash = build_facet_filters
    fullhash = combine_search_and_facet_queries(queryhash, filterhash)
    
    # Get information needed to display results nicely
    fieldhash = AllFacetsQuery.get_all_categories(@field_info)
    highlighthash = specify_fields_to_highlight(queryhash, highlighthash)

    query = {size: 1000, query: fullhash, facets: fieldhash,
               highlight: { pre_tags: ["<b>"], post_tags: ["</b>"], fields: highlighthash}}
    
    Nsadoc.search query
  end

  # Convert date into appropriate format for elasticsearch
  def parse_date(date)
    parseddate = date.split("/")
    return "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"
  end

  # Truncate highlighted field only when needed
  def highlightLength(fieldName)
    @field_info.each do |f|
      if f["Field Name"] == fieldName
        if f["Truncate"]
          return {}
        else return {number_of_fragments: 0}
        end
      end
    end
  end
end
