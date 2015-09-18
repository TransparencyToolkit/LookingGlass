module HighlightQuery
  # Figure out which fields to highlight based on which ones were searched for   
  def specify_fields_to_highlight(queryhash, highlighthash)
    if !queryhash.empty? && queryhash[:simple_query_string]
        queryhash[:simple_query_string][:fields].each do |k|
        if k == "_all"
          @all_field_info.each {|f| highlighthash[f["Field Name"]] = highlightLength(f["Field Name"])}
        else
          highlighthash[k] = highlightLength(k.to_s)
        end
      end
    end
   
    return highlighthash
  end

  # Truncate highlighted field only when needed
  def highlightLength(fieldName)
    # SHOULD CHECK WITH DATASPEC, NOT TOTALLY SAFE
    if @all_truncated_fields.include?(fieldName)
      return {}
    else
      return {number_of_fragments: 0}
    end
  end
end
