# -*- coding: utf-8 -*-
module CategoryFormat
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
  def genFacet(categories, outhtml, field_spec)
    category_name = field_spec["Field Name"]+"_facet" 
    categories_chosen = params[category_name] 

    # Overflow settings                                                                   
    totalnum = categories[field_spec["Field Name"]]["terms"].count 
    numshow = totalnum > 5 ? 5+totalnum*0.01 : totalnum 
   
    # Split results into top and overflow
    sorted_results = categories[field_spec["Field Name"]]["terms"].sort {|a,b| b["count"] <=> a["count"]}
    top_results = sorted_results[0..numshow]
    overflow_results = sorted_results[numshow+1..sorted_results.length-1]

    # Generate output html
    outhtml = genCategoryList(top_results, false, categories_chosen, category_name, field_spec)
    outhtml += genCategoryList(overflow_results, true, categories_chosen, category_name, field_spec) if overflow_results
    outhtml += "</ul></li></ul><br />"
    return outhtml
  end

  # Generates the html for a list of categories
  def genCategoryList(items, is_overflow, categories_chosen, category_name, field_spec)
    if is_overflow
      list_html = '<li><label class="tree-toggler nav-header plus"></label>
                        <ul class="nav nav-list tree collapse">'
    else
      list_html = '<ul class="nav nav-list">
                     <li><label class="tree-toggler nav-header just-plus">'+field_spec["Human Readable Name"]+'</label>
                      <ul class="nav nav-list tree collapse">'
    end

    # Generate link text for each item
    items.each do |i|
      list_html += termLink(i, categories_chosen, category_name)
    end

    list_html += "</li></ul>" if is_overflow
    
    return list_html
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

end
