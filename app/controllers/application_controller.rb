require 'will_paginate/array'

class ApplicationController < ActionController::Base
  include ParamParsing
  
  before_action :params_to_ignore
  
end
