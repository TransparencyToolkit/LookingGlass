module FieldQuery
  # Builds the query based on input to search fields
  def build_search_query
    # If searching by date
    if get_field_type == "Date"
      queryhash = {range: { @fieldnames[0] => {gte: @input[:start_date], lte: @input[:end_date]}}}

    # If searching by any other field
    elsif @fieldnames[0] != nil
      queryhash = {
        query_string: {
          query: @input[:searchterm],
          fields: [@fieldnames[0]],
          default_operator: "AND"
        }}
        #  flags: "AND|OR|PHRASE|PREFIX|NOT|FUZZY|SLOP|NEAR",
    else
      queryhash = {}
    end

    return queryhash
  end

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
end
