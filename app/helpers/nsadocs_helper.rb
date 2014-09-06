module NsadocsHelper
  def facetFormat(facets)
    outhtml = ""
    
    outhtml += '<ul class="nav nav-list">
            <li><label class="tree-toggler nav-header">- Programs</label><ul class="nav nav-list tree">'

    totalnum = facets["programs"]["terms"].count # maybe not needed
    cutoff = 5 # Make this automatically calculated or cut off lowest %
    overflow = '<li><label class="tree-toggler nav-header"></label><ul class="nav nav-list tree collapse">'
    facets["programs"]["terms"].each do |i|
      if totalnum > 20 && i["count"] < cutoff
        overflow += "<li>"+ i["term"] + " (" + i["count"].to_s + ")</li>"
      else
        outhtml += "<li>"+ i["term"] + " (" + i["count"].to_s + ")</li>"
      end
    end
    outhtml += "#{overflow}</ul></li></ul>"
    return outhtml
    # Change + to -
    # Cut off bottom % of menu when over certain lenth
    # Move show less to bottom (rather than heading) and change to -

    # Indent/clean up sidebar
    # Move js out of view

    # Add other fields
  end
end
