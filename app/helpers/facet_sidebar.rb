module FacetSidebar
  # Format the facet sidebar
  def format_facet_sidebar(facets)
    facet_fields = get_facets_for_project(ENV['PROJECT_INDEX'])

    # Generate the output html
    return facet_fields.inject("") do |facet_html, field|
      facet_html += format_facet_field(field, facets[field[0]]).to_s
    end
  end

  # Format the facet field
  def format_facet_field(field, aggr_response)
    list_header = '<ul class="nav nav-list"><li>'
    facet_header = generate_facet_header(field, aggr_response)
    tree_start = '<ul class="nav nav-list tree collapse">'
    tree_end = '</ul></li></ul></br>'

    bucket_items_initial = aggr_response["buckets"][0..10].map{|bucket| gen_facet_bucket_link(bucket)}.compact

    # Handle facet overflow
    overflow = ""
    if aggr_response["buckets"].length > 11
      bucket_items_remaining = aggr_response["buckets"][11..aggr_response["buckets"].length-1].map{|bucket| gen_facet_bucket_link(bucket)}.compact

      overflow = '<li><label class="tree-toggler nav-header plus"></label>
                        <ul class="nav nav-list tree collapse">'+bucket_items_remaining.join("")+'</li></ul>'
    end

    return list_header+facet_header+tree_start+bucket_items_initial.join("")+overflow+tree_end
  end

  # Generate a link for a facet bucket
  def gen_facet_bucket_link(bucket)
    return "<li>#{bucket['key']} (#{bucket['doc_count']})</li>" if !bucket['key'].empty?
  end

  # Generates the facet header
  def generate_facet_header(field, aggr)
    # Get different field values
    hr_name = field[1]["human_readable"]
    icon = field[1]["icon"]
    bucket_count = aggr["buckets"].length.to_s

    return '<label class="tree-toggler nav-header just-plus" title="' + bucket_count + ' Filters"><i class="icon-'+icon + '"></i>' + hr_name + '</label>'
  end
end
