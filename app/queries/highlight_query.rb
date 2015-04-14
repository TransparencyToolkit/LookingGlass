module HighlightQuery
  # Figure out which fields to highlight based on which ones were searched for   
  def specify_fields_to_highlight(queryhash, highlighthash)
      if !queryhash.empty? && queryhash[:simple_query_string][:fields]
        queryhash[:simple_query_string][:fields].each do |k|
        if k == "_all"
          @field_info.each {|f| highlighthash[f["Field Name"]] = highlightLength(f["Field Name"])}
        else
          highlighthash[k] = highlightLength(k.to_s)
        end
      end
    end

    return highlighthash
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
