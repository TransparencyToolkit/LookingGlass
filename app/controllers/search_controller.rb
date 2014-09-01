class SearchController < ApplicationController
  def index
    if params[:q]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { _all: {query: params[:q], fuzziness: "auto" }}},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:title]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { title: { query: params[:title], fuzziness: "auto" } } },
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:aclu_desc]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { aclu_desc: { query: params[:aclu_desc], fuzziness: "auto"} }},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:doc_text]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { doc_text: { query: params[:doc_text], fuzziness: "auto" } }},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:programs]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { programs_analyzed: { query: params[:programs].gsub(" ", ""), fuzziness: "auto"}}},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:codewords]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { codewords_analyzed: { query: params[:codewords].gsub(" ", ""), fuzziness: "auto"}}},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:creation_date]
      parseddate = params[:creation_date].split("/")
      dateclean = "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"
      
      if !params[:end_create_date].empty?
        parsed_end_date = params[:end_create_date].split("/")
        enddateclean = "#{parsed_end_date[2]}-#{parsed_end_date[0]}-#{parsed_end_date[1]}"
        
        @nsadocs = Nsadoc.search size: 1000, query: {range: { creation_date: {gte: dateclean, lte: enddateclean} } },
        facets: {
          programs: {terms: {field: "programs"}},
          codewords: {terms: {field: "codewords"}},
          type: {terms: {field: "type"}},
          records_collected: {terms: {field: "records_collected"}},
          legal_authority: {terms: {field: "legal_authority"}},
          countries: {terms: {field: "countries"}},
          sigads: {terms: {field: "sigads"}},
          released_by: {terms: {field: "released_by"}}
        }
      @facets = @nsadocs.response["facets"]
      else
        @nsadocs = Nsadoc.search size: 1000, query: {term: { creation_date: dateclean}},
        facets: {
          programs: {terms: {field: "programs"}},
          codewords: {terms: {field: "codewords"}},
          type: {terms: {field: "type"}},
          records_collected: {terms: {field: "records_collected"}},
          legal_authority: {terms: {field: "legal_authority"}},
          countries: {terms: {field: "countries"}},
          sigads: {terms: {field: "sigads"}},
          released_by: {terms: {field: "released_by"}}
        }
        @facets = @nsadocs.response["facets"]
      end
    elsif params[:type]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { type_analyzed: { query: params[:type], fuzziness: "auto" } }},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:records_collected]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { records_collected_analyzed: { query: params[:records_collected], fuzziness: "auto" } }},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:legal_authority]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { legal_authority_analyzed: { query: params[:legal_authority], fuzziness: "auto" } }},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:countries]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { countries_analyzed: { query: params[:countries], fuzziness: "auto" } }},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:sigads]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { sigads_analyzed: { query: params[:sigads], fuzziness: "auto" } }},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    elsif params[:release_date]
      parseddate = params[:release_date].split("/")
      dateclean = "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"

      if !params[:end_release_date].empty?
        parsed_end_date = params[:end_release_date].split("/")
        enddateclean = "#{parsed_end_date[2]}-#{parsed_end_date[0]}-#{parsed_end_date[1]}"

        @nsadocs = Nsadoc.search size: 1000, query: {range: { release_date: {gte: dateclean, lte: enddateclean} } },
        facets: {
          programs: {terms: {field: "programs"}},
          codewords: {terms: {field: "codewords"}},
          type: {terms: {field: "type"}},
          records_collected: {terms: {field: "records_collected"}},
          legal_authority: {terms: {field: "legal_authority"}},
          countries: {terms: {field: "countries"}},
          sigads: {terms: {field: "sigads"}},
          released_by: {terms: {field: "released_by"}}
        }
        @facets = @nsadocs.response["facets"]
      else
        @nsadocs = Nsadoc.search size: 1000, query: {term: { release_date: dateclean}},
        facets: {
          programs: {terms: {field: "programs"}},
          codewords: {terms: {field: "codewords"}},
          type: {terms: {field: "type"}},
          records_collected: {terms: {field: "records_collected"}},
          legal_authority: {terms: {field: "legal_authority"}},
          countries: {terms: {field: "countries"}},
          sigads: {terms: {field: "sigads"}},
          released_by: {terms: {field: "released_by"}}
        }
        @facets = @nsadocs.response["facets"]
      end

    elsif params[:released_by]
      @nsadocs = Nsadoc.search size: 1000, query: { match: { released_by_analyzed: { query: params[:released_by], fuzziness: "auto" } }},
      facets: {
        programs: {terms: {field: "programs"}},
        codewords: {terms: {field: "codewords"}},
        type: {terms: {field: "type"}},
        records_collected: {terms: {field: "records_collected"}},
        legal_authority: {terms: {field: "legal_authority"}},
        countries: {terms: {field: "countries"}},
        sigads: {terms: {field: "sigads"}},
        released_by: {terms: {field: "released_by"}}
      }
      @facets = @nsadocs.response["facets"]
    end
  end
end
