class SearchController < ApplicationController        
  def index
    queryhash = Hash.new

    # Set the input hash (field and value) for the appropriate field
    fieldList = JSON.parse(File.read("app/dataspec/nsadata.json"))
    fieldhash = Hash.new

    if params[:q] then queryhash = {field: "_all", searchterm: params[:q]} # Search all fields 
    else # For searching individual fields
      fieldList.each do |f|
        if f["Searchable?"] == "Yes"
          if params[f["Field Name"].to_sym]
            fieldname = f["Facet?"] == "Yes" ? (f["Field Name"]+"_analyzed").to_sym: f["Field Name"].to_sym

            # Check if it is a date and handle input differently if so
            if f["Type"] == "Date"
              startd = parse_date(params[f["Form Params"][0].to_sym])

              # Check if there is an end date or just a start date
              params[f["Form Params"][1].to_sym].empty? ? endd = Time.now : endd = parse_date(params[f["Form Params"][1].to_sym]) 
              queryhash = {field: fieldname, start_date: startd, end_date: endd}

            # If not a date
            else
              searchinput = params[f["Field Name"].to_sym]
              queryhash = {field: fieldname, searchterm: searchinput}
            end
            break
          end
        end
      end
    end

    queryhash == nil if queryhash.empty?
    
    # Maintains previously selected facets too
    facets = params.select { |i| i.include? "_facet" }
    
    # Build query, get documents, get facets
    @nsadocs = build_query(queryhash, facets)
    @facets = @nsadocs.response["facets"]
  end

  private

  # Convert date into appropriate format for elasticsearch
  def parse_date(date)
    parseddate = date.split("/")
    return "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"
  end

  # Generate the query from query hash
  def build_query(input, filter_by)
    # Generate query hash
    if input
      fieldnames = [input[:field]]
      queryhash = {}
    
      # Generate appropriate query hash (for single query)
      if input[:field] == :creation_date || input[:field] == :release_date
        queryhash = {range: { fieldnames[0] => {gte: input[:start_date], lte: input[:end_date]}}}
      elsif fieldnames[0] != nil
        queryhash = { bool: { should: [
                       { match: { fieldnames[0] => {query: input[:searchterm], type: "phrase" }}},
                       { match: { fieldnames[0] => {query: input[:searchterm]}}}
                    ]}}
      end
    end

    # Generate filters for faceted browsing
    hasharr = Array.new
    filter_by.each do |k, v|
      if v.is_a? Array
        v.each { |j| hasharr.push({ term: { k.gsub("_facet", "") => j}})}
      else
        hasharr.push({ term: { k.gsub("_facet", "") => v}})
      end
    end
    filterhash = { "and" => hasharr }

    
    # Options based on if it is search and facets, just facets, just search
    if !filter_by.empty? && !queryhash.empty?
      fullhash = { filtered: { query: queryhash, filter: filterhash }} 
    elsif queryhash.empty?
      fullhash = { filtered: { filter: filterhash}}
    else
      fullhash = queryhash
    end

    # Put it all together
    fieldList = JSON.parse(File.read("app/dataspec/nsadata.json"))
    fieldhash = Hash.new
    fieldList.each do |f|
      if f["Facet?"] == "Yes"
        fieldhash[f["Field Name"].to_sym] = {terms: {field: f["Field Name"], size: f["Size"]}}
      end
    end
   
    # Specify which fields to highlight (based on which are searched)
    highlighthash = Hash.new
 
    if !queryhash.empty?
      queryhash[:bool][:should][0][:match].keys.each do |k|
        if k == "_all"
          fieldList.each {|f| highlighthash[f["Field Name"]] = highlightLength(f["Field Name"])}
        else
          highlighthash[k] = highlightLength(k.to_s)
        end
      end
    end
                                                                                              
    query = {size: 1000, query: fullhash, facets: fieldhash, highlight: { pre_tags: ["<b>"], post_tags: ["</b>"], fields: highlighthash }}
    
    Nsadoc.search query
  end

  # Truncate highlighted field only when needed
  def highlightLength(fieldName)        
    fieldList = JSON.parse(File.read("app/dataspec/nsadata.json"))

    fieldList.each do |f|
      if f["Field Name"] == fieldName
        if f["Truncate"] 
          return {} 
        else return {number_of_fragments: 0}
        end
      end
    end
  end
end
