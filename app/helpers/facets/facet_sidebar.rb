module FacetSidebar
  # Get the list of facets for the sidebar
  def get_facet_list_for_sidebar
    return get_facets_for_project(ENV['PROJECT_INDEX'])
  end

  # Load the variables for a specific facet field
  def load_vars_for_facet_tree(field, facets)
    @aggregation = facets[field[0]]
    @hr_name = field[1]["human_readable"]
    @icon = field[1]["icon"]
    @bucket_count = @aggregation["buckets"].length.to_s
  end
end
