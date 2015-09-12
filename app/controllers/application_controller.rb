require 'will_paginate/array'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include DataspecUtils
  include MultiDataset

  before_action :load_dataspec
  
  private 

  def load_dataspec
    loadAllDatasets
    create_all_models

    # Load general vars
    get_all_facets
    get_all_field_info
  end
end
