class SearchController < ApplicationController
  def index
    if params[:q]
      @nsadocs = Nsadoc.search(params[:q])
    elsif params[:title]
      @nsadocs = Nsadoc.search query: { match: { title: params[:title] } }
    end
  end
end
