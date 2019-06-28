class CatalystController < ApplicationController
  include CatalystApi

  def basic
    render 'catalyst/basic'
  end

  def advanced
    render 'catalyst/advanced'
  end

  def index
    recipes = get_recipes_for_index(ENV["PROJECT_INDEX"])

    recipes.each_with_index do |recipe, index|
        recipe["annotators"] = get_annotators_for_recipe(recipe["id"])

        puts recipe["docs_to_process"]["run_over"]

        if recipe["docs_to_process"]["run_over"] == "within_range"
            recipe["total_mined_count"] = get_within_range_count(
                recipe["index_name"],
                recipe["docs_to_process"]["field_to_search"],
                recipe["docs_to_process"]["filter_query"],
                recipe["docs_to_process"]["end_filter_range"],
                recipe["doc_type"])
        elsif recipe["docs_to_process"]["run_over"] == "matching_query"
            recipe["total_mined_count"] = get_matching_docs_count(
                recipe["index_name"],
                recipe["docs_to_process"]["field_to_search"],
                recipe["docs_to_process"]["filter_query"],
                recipe["doc_type"])
        else
            recipe["total_mined_count"] = "Unknown"
        end

        recipe["total_doc_count"] = get_total_doc_count_for_type(recipe["index_name"], recipe["doc_type"])
    end

    render 'catalyst/index', :locals => { :recipes => recipes }
  end
end
