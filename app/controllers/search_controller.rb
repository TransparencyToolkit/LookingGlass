class SearchController < ApplicationController
  def index
    queryhash = Hash.new

    # Set the input hash (field and value) for the appropriate field
    fieldhash = Hash.new

    if params[:q] then queryhash = {field: "_all", searchterm: params[:q]} # Search all fields 
    else # For searching individual fields
      @field_info.each do |f|
        if f["Searchable?"] == "Yes"
          if params[f["Field Name"].to_sym]
            fieldname = f["Facet?"] == "Yes" ? (f["Field Name"]+"_analyzed").to_sym: f["Field Name"].to_sym

            # Check if it is a date and handle input differently if so
            if f["Type"] == "Date"
              startd = parse_date(params[f["Form Params"][0].to_sym])

              # Check if there is an end date or just a start date
              if params[f["Form Params"]]
                        params[f["Form Params"][1].to_sym].empty? ? endd = Time.now : endd = parse_date(params[f["Form Params"][1].to_sym]) 
              end
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
    #@nsadocs = build_query(queryhash, facets)
    s = SearchQuery.new(queryhash, facets, @field_info)
    @nsadocs = s.build_query
    @facets = @nsadocs.response["facets"]
  end
end
