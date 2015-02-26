# -*- coding: utf-8 -*-

module NsadocsHelper
  def format_text(text)
    text.gsub("\n", "<br />")
  end

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

  # Gets the human readable name of a facet
  def getHR(name)
    @field_info.each do |i|
      if i["Field Name"] == name
        return i["Human Readable Name"]
      end
    end
  end

  # Generates links to data filtered by facet val
  def linkedFacets(field_vals, field_name)
    outstr = ""

    if field_vals.is_a?(Array)
      # Generate links for each value in list of facet vals
      field_vals.each do |i|
        outstr += link_to(i, search_path((field_name+"_facet").to_sym => i))
        outstr += ", " if i != field_vals.last
      end
    else # For single values
      outstr += link_to(field_vals, search_path((field_name+"_facet").to_sym => field_vals))
    end
    return outstr
  end

  # Get list of items in table and their names
  def tableItems
    itemarr = Array.new


    #items = JSON.parse(File.read("app/dataspec/nsadata.json"))
    #sortItems = items.sort_by{|item| item["Location"].to_i}
    @field_info_sorted.each do |i|
      if i["In Table?"] == "Yes"
        itemarr.push(i)
      end
    end
    
    return itemarr
  end

  def facetFormat(facets)
    outhtml = ""
       
    # Go through all facets
    @field_info_sorted.each do |f|
      if f["Facet?"] == "Yes"
        outhtml += genFacet(facets, "", f) if facets[f["Field Name"]]["terms"].count > 0
      end
    end
    return outhtml
  end

  # Gen html for list of links for each facet
  def genFacet(facets, outhtml, type)
    outhtml += '<ul class="nav nav-list">
            <li><label class="tree-toggler nav-header just-plus">'+type["Human Readable Name"]+'</label><ul class="nav nav-list tree collapse">'
    facetname = type["Field Name"]+"_facet"
    facetval = params[facetname]
    
    
    # Overflow settings
    totalnum = facets[type["Field Name"]]["terms"].count
    numshow = totalnum > 5 ? 5+totalnum*0.01 : totalnum
    overflow = '<li><label class="tree-toggler nav-header plus"></label><ul class="nav nav-list tree collapse">'
    counter = 0

    # Add each facet to output or overflow list
    facets[type["Field Name"]]["terms"].each do |i|
      if counter > numshow
        overflow += termLink(i, facetval, facetname)
      else
        outhtml += termLink(i, facetval, facetname)
      end
      counter += 1
    end

    overflow += "</li></ul>"
    outhtml += "#{overflow}" if counter > numshow
    outhtml += "</ul></li></ul><br />"
    return outhtml
  end

  # Generate link html for each term in facet list
  def termLink(i, facetval, facetname)
    linkname = "#{i["term"]} (#{i["count"].to_s})"

    # Check if link is selected or not
    if facetval == i["term"] || (facetval.is_a?(Array) && facetval.include?(i["term"]))
      return ""
    else
      return notSelected(i, facetval, facetname, linkname)
    end
  end

  # Generate link for selected facet
  def selected(i, facetval, facetname, linkname)
    # Check if there are other facets selected (in this category or others)
    if params.except("controller", "action", "utf8", facetname).length > 0 || facetval.is_a?(Array)
      # Are there other facets selected in this category?                   
      if facetval.is_a?(Array)
        outval = facetval.dup
        outval.delete(i["term"])
        outval = outval[0] if facetval.count <= 2
        return genLink(linkname, search_path(params.except(facetname).merge(facetname => outval)), true)
      else # If no others in category selected
        return genLink(linkname, search_path(params.except(facetname)), true)
      end
    else # If no others selected
      return genLink(linkname, root_path, true)
    end
  end

  # If facet is not selected, generate link
  def notSelected(i, facetval, facetname, linkname)
    retstr = ""
    if facetval # Check if another facet in the same category is selected
      facetvals = facetval.is_a?(Array) ? facetval.dup.push(i["term"]) : [facetval, i["term"]]
      retstr = genLink(linkname, search_path(params.merge("utf8" => "✓", facetname => facetvals)), false)
      params.except(facetname).merge(facetname => facetval)
    else
      retstr = genLink(linkname, search_path(params.merge("utf8" => "✓", facetname => i["term"])), false)
      params.except(facetname)
    end

    return retstr
  end

  # Generate link html
  def genLink(name, path, em)
    return (em ? "<li><em>" : "<li>") + link_to(name, path) + (em ? "</li></em>" : "</li>")
  end
end
