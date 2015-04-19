class SearchQuery
  include FacetsQuery
  include FieldQuery
  include HighlightQuery
  include DateParser
  include ParamParser

  def initialize(params, field_info)
    @params = params
    @field_info = field_info
  end

  # Calls methods to process params and put together query
  def build_query
    # Initial processing of query and facet parameters
    @input = process_params                                
    @filter_by = @params.select { |i| i.include? "_facet" }
    
    @fieldnames = [@input[:field]]
    queryhash = {}
    highlighthash = Hash.new

    # Form specific query for parameters passed
    queryhash = build_search_query
    filterhash = build_facet_filters
    fullhash = combine_search_and_facet_queries(queryhash, filterhash)
    
    # Get information needed to display results nicely
    fieldhash = get_all_categories(@field_info)
    highlighthash = specify_fields_to_highlight(queryhash, highlighthash)
    
    query = {size: Nsadoc.count, query: fullhash, facets: fieldhash,
               highlight: { pre_tags: ["<b>"], post_tags: ["</b>"], fields: highlighthash}}
    return query
  end


end
