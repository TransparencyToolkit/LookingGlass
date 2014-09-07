# -*- coding: utf-8 -*-
module NsadocsHelper
  def facetFormat(facets)
    outhtml = ""
    facetNames = {"programs" => "Programs", "codewords" => "Codewords", "type" => "Document Type", 
    "records_collected" => "Records Collected", "legal_authority" => "Legal Authority", "countries" => "Countries",
    "sigads" => "SIGADS", "released_by" => "Released By"}
    
    facetNames.each do |f|
      outhtml += genFacet(facets, "", f) if facets[f[0]]["terms"].count > 0
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
        if params[type[0]+"_facet"] == i["term"] || (params[type[0]+"_facet"].is_a?(Array) && params[type[0]+"_facet"].include?(i["term"]))
          # Direct to root path if there's no other query or filters
          if params.except("controller", "action", "utf8", type[0]+"_facet").length > 0 || params[type[0]+"_facet"].is_a?(Array)
            overflow += "<li><em>"+link_to("#{i["term"]} (#{i["count"].to_s})", search_path(params.except("utf8", type[0]+"_facet")))+"</em></li>"
          else
            overflow += "<li><em>"+link_to("#{i["term"]} (#{i["count"].to_s})", root_path)+"</li></em>"
          end
        else
          # Normal links
          if params[type[0]+"_facet"]
            facetvals = params[type[0]+"_facet"].is_a?(Array) ? params[type[0]+"_facet"].push(i["term"]) : [params[type[0]+"_facet"], i["term"]]
            overflow += "<li>"+link_to("#{i["term"]} (#{i["count"].to_s})", search_path(params.merge("utf8" => "✓", type[0]+"_facet" => facetvals)))+"</li>"
          else
            overflow += "<li>"+link_to("#{i["term"]} (#{i["count"].to_s})", search_path(params.merge("utf8" => "✓", type[0]+"_facet" => i["term"])))+"</li>"
          end
      end
      else
        # Show normal or highlighted link
        if params[type[0]+"_facet"] == i["term"] || (params[type[0]+"_facet"].is_a?(Array) && params[type[0]+"_facet"].include?(i["term"]))
          # Direct to root path if there's no other query or filters
          if params.except("controller", "action", "utf8", type[0]+"_facet").length > 0 || params[type[0]+"_facet"].is_a?(Array)
            # Handle if it is an array or not
            if params[type[0]+"_facet"].is_a?(Array)
              outval = params[type[0]+"_facet"].count #write this
              outhtml += "<li><em>"+link_to("#{i["term"]} (#{i["count"].to_s})", search_path(params.except(type[0]+"_facet").merge(type[0]+"_facet" => outval)))+"</em></li>"
              # Test one case
              # Test two cases
              # Test 3 cases
              # Add to overflow
            else
              outhtml += "<li><em>"+link_to("#{i["term"]} (#{i["count"].to_s})", search_path(params.except(type[0]+"_facet")))+"</em></li>"
            end
          else
            outhtml += "<li><em>"+link_to("#{i["term"]} (#{i["count"].to_s})", root_path)+"</li></em>"
          end
        else
          if params[type[0]+"_facet"]
            facetvals = params[type[0]+"_facet"].is_a?(Array) ? params[type[0]+"_facet"].push(i["term"]) : [params[type[0]+"_facet"], i["term"]]
            outhtml += "<li>"+link_to("#{i["term"]} (#{i["count"].to_s})", search_path(params.merge("utf8" => "✓", type[0]+"_facet" => facetvals)))+"</li>"
          else
            outhtml += "<li>"+link_to("#{i["term"]} (#{i["count"].to_s})", search_path(params.merge("utf8" => "✓", type[0]+"_facet" => i["term"])))+"</li>"
          end
        end 
      end
      counter += 1
    end
    overflow += "</li></ul>"
    outhtml += "#{overflow}" if counter > numshow
    outhtml += "</ul></li></ul><br />"
    return outhtml
  end
end
