module ModelGen
  # Generate mapping based on dataspec/settings
  def genMapping(settings, dataspec)
    fieldhash = Hash.new
    
    dataspec.field_info.each do |f|
      # Set mapping
      map = fieldMapping(f)

      # If facet, make separate analyzed version.
      if dataspec.facet_fields.include?(f["Field Name"])
        addToMapping(f, f["Field Name"], map)
        duplicateUnanalyzedFacet(f)
      else # For non-facets
        addToMapping(f, f["Field Name"], map)
      end
    end
  end

  # Add non-facet field to mapping (name, data type, mapping)
  def addToMapping(f, field_name, map)
    return attribute field_name.to_sym, f["Type"], mapping: map
  end

  # Make a duplicate that isn't analyzed for facets
  def duplicateUnanalyzedFacet(f)
    return attribute (f["Field Name"]+"_facet").to_sym, f["Type"], mapping: {index: "not_analyzed", fielddata: {format: "doc_values"}}
  end

  # Generate mapping for particular field
  def fieldMapping(f)
    map = Hash.new

    # Set to correct analyzer
    if f["Mapping"] == "not_analyzed"
      map[:index] = f["Mapping"]
    elsif f["Mapping"] == "english"
      map[:analyzer] = "custom_en_analyzer"
    end

    return map
  end
end
