class SearchController < ApplicationController
  def index
    if params[:q]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { _all: {query: params[:q], fuzziness: "auto" }}}
    elsif params[:title]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { title: { query: params[:title], fuzziness: "auto" } } }
    elsif params[:aclu_desc]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { aclu_desc: { query: params[:aclu_desc], fuzziness: "auto"} }}
    elsif params[:doc_text]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { doc_text: { query: params[:doc_text], fuzziness: "auto" } }}
    elsif params[:programs]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { programs_analyzed: { query: params[:programs].gsub(" ", ""), fuzziness: "auto"}}}
    elsif params[:codewords]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { codewords_analyzed: { query: params[:codewords].gsub(" ", ""), fuzziness: "auto"}}}
    elsif params[:creation_date]
      parseddate = params[:creation_date].split("/")
      dateclean = "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"
      
      if !params[:end_create_date].empty?
        parsed_end_date = params[:end_create_date].split("/")
        enddateclean = "#{parsed_end_date[2]}-#{parsed_end_date[0]}-#{parsed_end_date[1]}"
        
        @nsadocs = Nsadoc.search size: 1000, query: {range: { creation_date: {gte: dateclean, lte: enddateclean} } }
      else
        @nsadocs = Nsadoc.search size: 1000, query: {term: { creation_date: dateclean}}
      end
    elsif params[:type]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { type_analyzed: { query: params[:type], fuzziness: "auto" } }}
    elsif params[:records_collected]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { records_collected_analyzed: { query: params[:records_collected], fuzziness: "auto" } }}
    elsif params[:legal_authority]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { legal_authority_analyzed: { query: params[:legal_authority], fuzziness: "auto" } }}
    elsif params[:countries]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { countries_analyzed: { query: params[:countries], fuzziness: "auto" } }}
    elsif params[:sigads]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { sigads_analyzed: { query: params[:sigads], fuzziness: "auto" } }}
    elsif params[:release_date]
      parseddate = params[:release_date].split("/")
      dateclean = "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"

      if !params[:end_release_date].empty?
        parsed_end_date = params[:end_release_date].split("/")
        enddateclean = "#{parsed_end_date[2]}-#{parsed_end_date[0]}-#{parsed_end_date[1]}"

        @nsadocs = Nsadoc.search size: 1000, query: {range: { release_date: {gte: dateclean, lte: enddateclean} } }
      else
        @nsadocs = Nsadoc.search size: 1000, query: {term: { release_date: dateclean}}
      end

    elsif params[:released_by]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { released_by_analyzed: { query: params[:released_by], fuzziness: "auto" } }}
    end
  end
end
