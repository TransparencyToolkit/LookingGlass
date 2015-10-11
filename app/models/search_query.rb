class SearchQuery
  include FacetsQuery
  include FieldQuery
  include HighlightQuery
  include DateParser
  include ParamParser
  include DataspecUtils

  def initialize(params, start)
    @params = params
    @start = start
    load_everything
  end

  # Calls methods to process params and put together query
  def build_query
    # Initial processing of query and facet parameters
    @input, @model_to_search, @dataspec_to_search = process_params
    @filter_by = @params.select { |i| i.include? "_facet" }
    
    @fieldnames = [@input[:field]]
    queryhash = {}
    highlighthash = Hash.new
    
    # Form specific query for parameters passed
    queryhash = build_search_query 
    filterhash = build_facet_filters
    fullhash = combine_search_and_facet_queries(queryhash, filterhash)
    
    # Get information needed to display results nicely
    fieldhash = @all_facets # CHECK ON ALL SEARCH AND ONE INDEX SEARCH
    #fieldhash = get_all_categories ONLY WORKS FOR ALL FACETS
    highlighthash = specify_fields_to_highlight(queryhash, highlighthash)
    
    query = {from: @start, size: 30, query: fullhash, facets: fieldhash,
               highlight: { pre_tags: ["<b class='is_highlighted'>"], post_tags: ["</b>"], fields: highlighthash}}
    
    return query, @model_to_search
  end


end
