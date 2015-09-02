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
    
    loadDataspec # TO REMOVE
  end
end
