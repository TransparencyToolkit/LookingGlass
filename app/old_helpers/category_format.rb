# -*- coding: utf-8 -*-
module CategoryFormat
  include GeneralUtils


  # Format facets on sidebar
  def facetFormat(facets)
    outhtml = ""

    # Print facets for each dataspec
    overlapping_facets = get_facet_union
    outhtml += print_facet_list(overlapping_facets, facets)

    # Print nonoverlapping facets for each dataspec
    @dataspecs.each do |dataspec|
      outhtml += '<div class="detail-heading">'+dataspec.dataset_name+' Filters</div>' if @dataspecs.length > 1
      nonoverlapping = dataspec.facet_fields.select{|f| !overlapping_facets.include?(f.to_sym)}
      outhtml += print_facet_list(nonoverlapping, facets)
    end

    return outhtml
  end

  # Print a list of facets
  def print_facet_list(facet_list, facets)
    outhtml = ""
    
    sortFields(facet_list, @all_field_info).each do |field|
      total_count = facets[field.to_sym]["terms"].count.to_s
      outhtml += genFacet(facets, "", field.to_sym, total_count) if facets[field.to_sym]["terms"].count > 0
    end

    return outhtml
  end

  # Get lists of facets that are in more than one
  def get_facet_union
    facet_count = Hash[@all_facets.keys.map{|k| [k, 0]}]
    
    # Increment count for each time facet is used
    @dataspecs.each do |dataspec|
      dataspec.facet_fields.each do |facet|
        facet_count[facet.to_sym] += 1
      end
    end

    # Return those with a count above one
    return facet_count.select{|k, v| v > 1}.keys
  end  

  # Gen html for list of links for each facet
  def genFacet(categories, outhtml, field, total_count)
    category_name = field.to_s+"_facet"
    categories_chosen = params[category_name]

    top_results, overflow_results = splitResults(categories, field)
    return combinedHTML(top_results, overflow_results, categories_chosen, category_name, field, total_count)
  end

  # Splits the results into overflow/not overflow
  def splitResults(categories, field)
    # Overflow calculation settings
    totalnum = categories[field]["terms"].count
    numshow = totalnum > 5 ? 5+totalnum*0.01 : totalnum

    # Divides list of terms
    sorted_results = sortResults(categories, field)
    top_results = sorted_results[0..numshow]
    overflow_results = sorted_results[numshow+1..sorted_results.length-1]

    # Don't allow crazy long facet lists
    processed_overflow = overflow_results[0..500] if overflow_results
    return top_results, processed_overflow
  end

  # Sorts facets by number of results
  def sortResults(categories, field)
    return categories[field]["terms"].sort {|a,b| b["count"] <=> a["count"]}
  end

  # Generates HTML for category
  def combinedHTML(top_results, overflow_results, categories_chosen, category_name, field, total_count)
    outhtml = genPartialHTML(top_results, false, categories_chosen, category_name, field, total_count)
    outhtml += genPartialHTML(overflow_results, true, categories_chosen, category_name, field, total_count) if overflow_results
    outhtml += "</ul></li></ul><br />"
    return outhtml
  end

  # Generates the html for single category
  def genPartialHTML(items, is_overflow, categories_chosen, category_name, field, total_count)
    field_spec = getFieldDetails(field.to_s, @all_field_info) # Get field display details

    if is_overflow
      list_html = '<li><label class="tree-toggler nav-header plus"></label>
                        <ul class="nav nav-list tree collapse">'
    else
      list_html = '<ul class="nav nav-list">
                     <li>
                        <label class="tree-toggler nav-header just-plus" title="' + total_count + ' Filters">
                          <i class="icon-' + field_spec["Icon"] + '"></i>' + field_spec["Human Readable Name"] + '
                        </label>
                        <ul class="nav nav-list tree collapse">'
    end

    # Generate link text for each item
    items.each do |i|
      list_html += termLink(i, categories_chosen, category_name).to_s
    end

    list_html += "</li></ul>" if is_overflow

    return list_html
  end
end
