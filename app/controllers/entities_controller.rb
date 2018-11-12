class EntitiesController < ApplicationController
  include IndexApi

  def index
      dataspecs = get_dataspecs_for_project(ENV["PROJECT_INDEX"])
      @entity_specs = dataspecs.select{|spec| spec["class_name"].include?("Entity")}
      render 'index'
  end

  def create
      dataspecs = get_dataspecs_for_project(ENV["PROJECT_INDEX"])
      entity_specs = dataspecs.select{|spec| spec["class_name"].include?("Entity")}
      entity_specs.each do |entity|
          @entity = entity
          break if entity["class_name"] == params[:entity]
      end
      render 'create'
  end

  def save
      if ENV["WRITABLE"] == "true"
          doc_to_create = [params["edited"]["items"].to_h.to_a.map{|d| [d[0], d[1]["changed"]]}.to_h]
          save_data(ENV["PROJECT_INDEX"], params["edited"]["doc_type"], doc_to_create)
      end
  end

end
