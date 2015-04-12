module SearchedFormat
  # Formats the link to remove the facet 
  def removeFormat(hrname, k, v, type)
    outstr = '<span class="search-filter">'
    outstr += hrname+": "+ v + " (" + type + ")"

    # Either remove from search or go to index page                                                                    
    if params.length <= 4 && (!params[k].is_a?(Array) || params[k].length <= 1)
      outstr += link_to(raw('<b style="color: red" class="x"> X</b>'), nsadocs_path, :class => "remove-filter")
    else
      # If there are multiple vals chosen for category, just remove one                                    
      if params[k].is_a? Array
        saveparams = params[k]
        params[k] = params[k] - [v] # Remove value from array                                                                        
        outstr += link_to(raw('<b style="color: red" class="x"> X</b>'), search_path(params), :class => "remove-filter")
        params[k] = saveparams # Set it back to normal                                                    
      else # For single vals per category                                                   
        outstr += link_to(raw('<b style="color: red" class="x"> X</b>'), search_path(params.except(k)), :class => "remove-filter")
      end
    end

    outstr += '</span>'
  end

end
