module NsadocsHelper
  def facetFormat(facets)
    outhtml = ""
    
    outhtml += '<ul class="nav nav-list">
            <li><label class="tree-toggler nav-header">Programs</label><ul class="nav nav-list tree">'
    facets["programs"]["terms"].each do |i|
      outhtml += "<li>"+ i["term"] + " (" + i["count"].to_s + ")</li>"
    end
    outhtml += "</ul></li></ul>"
    return outhtml
    # Have menu start closed
    # Add +/-
    # Indent
    # Move js out of view

    # Add other fields
  end
end
