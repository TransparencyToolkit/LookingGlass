class DocsController < ApplicationController
  before_action :set_doc, only: [:show]
  include FacetsQuery
  include ControllerUtils
  include MultiDataset

  def description
    
  end

  def advancedsearch
  end

  # Handle attachments in directories other than the current one
  def attach
    path = "/"+params["path"]+"."+params["format"]
    send_file(path,
               :disposition => 'inline',
               :type => params["format"],
               :x_sendfile => true )
  end

  def index
    # Get docs, pages, and count
    pagenum, start = page_calc(params)
    docs = sort_results(start, @all_facets, @dataspecs.first)
    @total_count = get_total_docs 

    # Paginate documents
    @pagination = WillPaginate::Collection.create(pagenum, 30, @total_count) do |pager|
      pager.replace @docs
    end
  
    # Get facets and documents
    @facets = @docs.response["facets"]
    @docs = @docs.response["hits"]["hits"]
  end

  def show
    # Figure out if it has facet fields or not
    @dataspec = get_dataspec(@doc)
    @link_type = Hash.new
    set_link_field

    # Get the set of docs that go together
    @docs = ""
    get_matching_set(@doc["_source"])
    
    respond_to do |format|
      format.html
    end
  end

  private

  # Check if it includes index name
  def includes_index_name?(id, index_names)
    index_names.each do |i|
      return true if id.include?(i)
    end

    return false
  end

  # Leacy support for specific cases before multidataspec support
  def handle_legacy_id(id, index_names)
    # Change icwatch2 to icwatch
    if id.include?("icwatch2")
      return id.gsub("icwatch2", "icwatch")
    else # Append appropriate index
      append = index_names.select{|i| ["nsadocs", "icwatch_linkedin"].include?(i)}.first
      return id+append
    end
  end
  
  # Set the doc var to the correct item for the show view
  def set_doc
    # Get list of all index names
    index_names = @dataspecs.inject([]) {|arr,d| arr.push(d.index_name)}

    # Check if id includes index name
    if includes_index_name?(params[:id], index_names)
      id = params[:id]
    else # Legacy support for before multidataspec support
      id = handle_legacy_id(params[:id], index_names)
    end

    # Get document
    @doc = Elasticsearch::Model.search({query: { match: {"_id" => id}}}, @models).response["hits"]["hits"].first
  end

  # Sorts the results
  def sort_results(start, all_facet_fields, dataspec)
    if !dataspec.sort_field.empty?
      @docs = Elasticsearch::Model.search({sort: {dataspec.sort_field => "desc"}, from: start, size: 30, facets: all_facet_fields}, @models)
    else
      @docs = Elasticsearch::Model.search({from: start, size: 30, facets: all_facet_fields}, @models)
    end
  end

  # Set field that links items
  def set_link_field
    @dataspec.field_info.each do |f|
      if f["Link"]
          @link_type["Link Field"] = f["Field Name"]
          @link_type["Link Type"] = f["Link"]
      end
    end
  end
  
  # Get all items with matching link field
  def get_matching_set(doc)
    if @link_type["Link Type"] == "mult_items"
      @docs = Elasticsearch::Model.search({query:
                                            { match:
                                                {@link_type["Link Field"].to_sym => doc[@link_type["Link Field"]] }
                                            }, size: 999999}, @models).response["hits"]["hits"]
      @doc = ""
    else # Set to _source field of doc
      @doc = doc
    end
  end
end
