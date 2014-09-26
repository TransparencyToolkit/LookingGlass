class SearchController < ApplicationController
  def index
    queryhash = Hash.new

    # Set the input hash (field and value) for the appropriate field
    if params[:q] then queryhash = {field: "_all", searchterm: params[:q]}
    elsif params[:title] then queryhash = {field: :title, searchterm: params[:title]}
    elsif params[:aclu_desc] then queryhash = {field: :aclu_desc, searchterm: params[:aclu_desc]}
    elsif params[:doc_text] then queryhash = {field: :doc_text, searchterm: params[:doc_text]}
    elsif params[:programs] then queryhash = {field: :programs_analyzed, searchterm: params[:programs]}
    elsif params[:codewords] then queryhash = {field: :codewords_analyzed, searchterm: params[:codewords]}
    elsif params[:creation_date] 
      if !params[:end_create_date].empty? 
        queryhash = {field: :creation_date, start_date: parse_date(params[:creation_date]), 
          end_date: parse_date(params[:end_create_date])}
      else
        queryhash = {field: :creation_date, searchterm: parse_date(params[:creation_date])}
      end
    elsif params[:type] then queryhash = {field: :type_analyzed, searchterm: params[:type]}
    elsif params[:records_collected] then queryhash = {field: :records_collected_analyzed, searchterm: params[:records_collected]}
    elsif params[:legal_authority] then queryhash = {field: :legal_authority_analyzed, searchterm: params[:legal_authority]}
    elsif params[:countries] then queryhash = {field: :countries_analyzed, searchterm: params[:countries]}
    elsif params[:sigads] then queryhash = {field: :sigads_analyzed, searchterm: params[:sigads]}
    elsif params[:release_date]
      if !params[:end_release_date].empty?
        queryhash = {field: :release_date, start_date: parse_date(params[:release_date]), 
          end_date: parse_date(params[:end_release_date])}
      else
        queryhash = {field: :release_date, searchterm: parse_date(params[:release_date])}
      end

    elsif params[:released_by] then queryhash = {field: :released_by_analyzed, searchterm: params[:released_by]}
    else queryhash = nil
    end

    facets = params.select { |i| i.include? "_facet" }
    
    # Build query, get documents, get facets
    @nsadocs = build_query(queryhash, facets)
    @facets = @nsadocs.response["facets"]
  end

  private

  # Convert date into appropriate format for elasticsearch
  def parse_date(date)
    parseddate = date.split("/")
    return "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"
  end

  # Generate the query from query hash
  def build_query(input, filter_by)

    # Generate query hash
    if input
      fieldnames = [input[:field]]
      queryhash = {}
    
      # Generate appropriate query hash
      if input[:field] == :creation_date || input[:field] == :release_date
        if input[:end_date]
          queryhash = {range: { fieldnames[0] => {gte: input[:start_date], lte: input[:end_date]}}}
        else
          queryhash = {term: { fieldnames[0] => input[:searchterm]}}
        end
      else
        queryhash = { bool: { should: [
                       { match: { fieldnames[0] => {query: input[:searchterm], type: "phrase", fuzziness: "auto" }}},
                       { match: { fieldnames[0] => {query: input[:searchterm], fuzziness: "auto" }}}
                    ]}}
      end
    end

    # Generate filters for faceted browsing
    hasharr = Array.new
    filter_by.each do |k, v|
      if v.is_a? Array
        v.each { |j| hasharr.push({ term: { k.gsub("_facet", "") => j}})}
      else
        hasharr.push({ term: { k.gsub("_facet", "") => v}})
      end
    end
    filterhash = { "and" => hasharr }

    # Options based on if it is search and facets, just facets, just search
    if !filter_by.empty? && queryhash
      fullhash = { filtered: { query: queryhash, filter: filterhash }} 
    elsif !queryhash
      fullhash = { filtered: { filter: filterhash}}
    else
      fullhash = queryhash
    end

    # Put it all together                                                             
      query = {size: 1000, query: fullhash,
        facets: {
          programs: {terms: {field: "programs", size: 1000}},
          codewords: {terms: {field: "codewords", size: 1000}},
          type: {terms: {field: "type", size: 1000}},
          records_collected: {terms: {field: "records_collected", size: 1000}},
          legal_authority: {terms: {field: "legal_authority", size: 1000}},
          countries: {terms: {field: "countries", size: 1000}},
          sigads: {terms: {field: "sigads", size: 1000}},
          released_by: {terms: {field: "released_by", size: 1000}}
        }}
    
    Nsadoc.search query
  end
end
