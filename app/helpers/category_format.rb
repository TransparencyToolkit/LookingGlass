# -*- coding: utf-8 -*-
module CategoryFormat
  # Format all facets on sidebar
  def facetFormat(facets)
    outhtml = ""

    # Go through all facets 
    @field_info_sorted.each do |f|
      if f["Facet?"] == "Yes"
        total_count = facets[f["Field Name"]]["terms"].count.to_s;
        outhtml += genFacet(facets, "", f, total_count) if facets[f["Field Name"]]["terms"].count > 0
      end
    end
    return outhtml
  end

  # Gen html for list of links for each facet                                                 
  def genFacet(categories, outhtml, field_spec, total_count)
    category_name = field_spec["Field Name"]+"_facet" 
    categories_chosen = params[category_name] 

    top_results, overflow_results = splitResults(categories, field_spec)
    return combinedHTML(top_results, overflow_results, categories_chosen, category_name, field_spec, total_count)
  end

  # Splits the results into overflow/not overflow
  def splitResults(categories, field_spec)
    # Overflow calculation settings                             
    totalnum = categories[field_spec["Field Name"]]["terms"].count
    numshow = totalnum > 5 ? 5+totalnum*0.01 : totalnum
    
    # Divides list of terms
    sorted_results = sortResults(categories, field_spec)
    top_results = sorted_results[0..numshow]
    overflow_results = sorted_results[numshow+1..sorted_results.length-1]

    # Don't allow crazy long facet lists
    processed_overflow = overflow_results[0..500] if overflow_results
    return top_results, processed_overflow
  end

  # Sorts facets by number of results
  def sortResults(categories, field_spec)
    return categories[field_spec["Field Name"]]["terms"].sort {|a,b| b["count"] <=> a["count"]}
  end

  # Generates HTML for category
  def combinedHTML(top_results, overflow_results, categories_chosen, category_name, field_spec, total_count)
    outhtml = genPartialHTML(top_results, false, categories_chosen, category_name, field_spec, total_count)
    outhtml += genPartialHTML(overflow_results, true, categories_chosen, category_name, field_spec, total_count) if overflow_results
    outhtml += "</ul></li></ul><br />"
    return outhtml
  end

  # Generates the html for single category
  def genPartialHTML(items, is_overflow, categories_chosen, category_name, field_spec, total_count)
    if is_overflow
      list_html = '<li><label class="tree-toggler nav-header plus"></label>
                        <ul class="nav nav-list tree collapse">'
    else
      list_html = '<ul class="nav nav-list">
                     <li>
                        <label class="tree-toggler nav-header just-plus" title="' + total_count + ' Filters">
                          ' + image_tag(field_spec["Icon"]+"-24.png") + field_spec["Human Readable Name"] + '
                        </label>
                        <ul class="nav nav-list tree collapse">'
    end

    # Generate link text for each item
    items.each do |i|
      list_html += termLink(i, categories_chosen, category_name)
    end

    list_html += "</li></ul>" if is_overflow
    
    return list_html
  end
end
