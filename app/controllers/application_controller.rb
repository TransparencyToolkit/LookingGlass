require 'will_paginate/array'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include DataspecUtils

  before_action :load_dataspec
  
  private 

  def load_dataspec
    # Load dataspec paths
    dataspec_paths = JSON.parse(File.read("app/dataspec/importer.json"))[0]["Dataset Config"]
    @dataspecs = Array.new

    # Load all dataspecs into array
    dataspec_paths.each do |dataspec_dir|
      @dataspecs.push(DataspecContent.new(dataspec_dir))
    end
    
    loadDataspec # TO REMOVE
  end
end
