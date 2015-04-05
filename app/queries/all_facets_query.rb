module AllFacetsQuery
  # Specify which categories/facets to get info for on the sidebar- all of them 
  def AllFacetsQuery.get_all_categories(field_info)
    fieldhash = Hash.new
    field_info.each do |f|
      if f["Facet?"] == "Yes"
        fieldhash[f["Field Name"].to_sym] = {terms: {field: f["Field Name"], size: f["Size"]}}
      end
    end

    return fieldhash
  end
end
