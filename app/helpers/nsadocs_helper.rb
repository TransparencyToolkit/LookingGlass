module NsadocsHelper
  def facetFormat(facets)
    outhtml = ""
    facetNames = {"programs" => "Programs", "codewords" => "Codewords", "type" => "Document Type", 
    "records_collected" => "Records Collected", "legal_authority" => "Legal Authority", "countries" => "Countries",
    "sigads" => "SIGADS", "released_by" => "Released By"}

    facetNames.each do |f|
      outhtml += genFacet(facets, "", f)
    end
    return outhtml
  end

  def genFacet(facets, outhtml, type)
    outhtml += '<ul class="nav nav-list">
            <li><label class="tree-toggler nav-header just-minus">'+type[1]+'</label><ul class="nav nav-list tree">'

    # Overflow settings
    totalnum = facets[type[0]]["terms"].count
    numshow = totalnum > 5 ? 5+totalnum*0.01 : totalnum
    overflow = '<li><label class="tree-toggler nav-header plus"></label><ul class="nav nav-list tree collapse">'
    counter = 0

    # Add each facet to output or overflow
    facets[type[0]]["terms"].each do |i|
      if counter > numshow
        overflow += "<li>"+ i["term"] + " (" + i["count"].to_s + ")</li>"
      else
        outhtml += "<li>"+ i["term"] + " (" + i["count"].to_s + ")</li>"
      end
      counter += 1
    end
    overflow += "</li></ul>"
    outhtml += "#{overflow}" if counter > numshow
    outhtml += "</ul></li></ul><br />"
    return outhtml
  end
end
