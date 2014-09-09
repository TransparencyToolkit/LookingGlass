# -*- coding: utf-8 -*-

module NsadocsHelper
  def facetFormat(facets)
    outhtml = ""
    facetNames = {"programs" => "Programs", "codewords" => "Codewords", "type" => "Document Type", 
    "records_collected" => "Records Collected", "legal_authority" => "Legal Authority", "countries" => "Countries",
    "sigads" => "SIGADS", "released_by" => "Released By"}
    
    # Go through all facets
    facetNames.each do |f|
      outhtml += genFacet(facets, "", f) if facets[f[0]]["terms"].count > 0
    end
    return outhtml
  end

  # Gen html for list of links for each facet
  def genFacet(facets, outhtml, type)
    outhtml += '<ul class="nav nav-list">
            <li><label class="tree-toggler nav-header just-minus">'+type[1]+'</label><ul class="nav nav-list tree">'
    facetname = type[0]+"_facet"
    facetval = params[facetname]
    
    # Overflow settings
    totalnum = facets[type[0]]["terms"].count
    numshow = totalnum > 5 ? 5+totalnum*0.01 : totalnum
    overflow = '<li><label class="tree-toggler nav-header plus"></label><ul class="nav nav-list tree collapse">'
    counter = 0

    # Add each facet to output or overflow list
    facets[type[0]]["terms"].each do |i|
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
      return selected(i, facetval, facetname, linkname)
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
