class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :get_field_info

  private
  
  # Gets the field info from the field data template
  def get_field_info
    @importer = JSON.parse(File.read("app/dataspec/importer.json")).first
    @hide_columns_info = File.read(@importer["Hide Columns Template"])
    @field_info = JSON.parse(File.read(@importer["Data Template"]))
    @field_info_sorted = @field_info.sort_by{|field| field["Location"].to_i}
  end
  
end
