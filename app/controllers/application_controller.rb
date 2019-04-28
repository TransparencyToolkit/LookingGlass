require 'will_paginate/array'

class ApplicationController < ActionController::Base
  include ParamParsing
  
  before_action :params_to_ignore
  before_action :authenticate

  def authenticate
    if ENV['WRITEABLE'] == "true"
      # Verify access with account system
      archive_admin_cookie = cookies[:archive_auth_key]
      http = Curl.post("#{ENV['ARCHIVEADMIN_URL']}/can_access_archive", {archive_auth_key: archive_admin_cookie,
                                                                         archive_secret_key: ENV['ARCHIVE_SECRET_KEY'],
                                                                         index_name: ENV['PROJECT_INDEX']})
      has_access = JSON.parse(http.body_str)["has_access"]

      # Redirect if doesn't have access
      if has_access == "unauthenticated"
        redirect_to "#{ENV['ARCHIVEADMIN_URL']}/unauthenticated"
      elsif has_access == "no"
        redirect_to "#{ENV['ARCHIVEADMIN_URL']}/not_allowed"
      end
    end
  end
end
