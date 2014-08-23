class SearchController < ApplicationController
  def index
    @nsadocs = Nsadoc.search(params[:q])
  end
end
