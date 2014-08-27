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
    end
  end
end
