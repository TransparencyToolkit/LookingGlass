module FacetsQuery
  # Specify which categories/facets to get info for on the sidebar- all of them 
  def get_all_categories(field_info)
    fieldhash = Hash.new
    field_info.each do |f|
      if f["Facet?"] == "Yes"
        fieldhash[f["Field Name"].to_sym] = {terms: {field: f["Field Name"], size: f["Size"]}}
      end
    end

    return fieldhash
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
end
