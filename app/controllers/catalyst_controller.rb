class CatalystController < ApplicationController
  include CatalystApi

  def builder
    render 'catalyst/builder'
  end

  def index
    recipes = get_recipes_for_index(ENV["PROJECT_INDEX"])

    render 'catalyst/index', :locals => { :recipes => recipes }
  end
end
