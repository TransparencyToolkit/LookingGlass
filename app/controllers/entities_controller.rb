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
      if ENV["WRITEABLE"] == "true"
          if !params["edited"].nil? and !params["edited"]["doc_type"].nil? and !params["edited"]["items"].nil?
              doc_saved = save_data(ENV["PROJECT_INDEX"], params["edited"]["doc_type"], [params["edited"]["items"].to_h])
              if doc_saved
                  redirect_to controller: 'search', action: 'index'
              else
                  puts "Hrm, creating entity failed"
              end
          else
              puts "Oops, form data submitted is not correct"
          end
      else
          puts "LookingGlass is not configured to be writeable"
      end
  end

end
