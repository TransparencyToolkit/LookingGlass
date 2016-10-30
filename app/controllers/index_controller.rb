load 'lib/index_manager.rb'

class IndexController < ApplicationController
  # Remove specified items from index
  def remove_item
    # Get dataspec and doc class
    dataspec = get_dataspec_for_this_source("app/dataspec/dataspec-"+params["source"]+"/")
    doc_class = get_model(dataspec.index_name)

    # Loop through and remove items
    JSON.parse(params[:extracted_items]).each do |item|
      item_content = JSON.parse(item["item"])
      unique_id = dataspec.dataset_name+item["id"]
      IndexManager.process_tags_remove(item_content, dataspec, unique_id, doc_class)
    end
  end

  # Add all new items to index
  def add_new_item
    # Get dataspec and doc class
    dataspec = get_dataspec_for_this_source("app/dataspec/dataspec-"+params["source"]+"/")
    doc_class = get_model(dataspec.index_name)
    
    # Loop through and add items
    JSON.parse(params[:extracted_items]).each do |item|
      item_content = JSON.parse(item["item"])
      unique_id = dataspec.dataset_name+item["id"]
      IndexManager.process_tags_add(item_content, dataspec, unique_id, doc_class)
    end
  end

  # Load in the dataspec
  def find_dataspec
    # Load in data
    source = params["source"]
    config_file = "app/dataspec/instances/harvester_config.json"
    instance = JSON.parse(File.read(config_file))

    # Add new dataspec
    dataspec = "app/dataspec/dataspec-"+source+"/"
    instance["Dataset Config"].push(dataspec) if !instance["Dataset Config"].include?(dataspec)
    File.write(config_file, JSON.pretty_generate(instance))

    # Load in everything
    load_everything
    current_source_dataspec = get_dataspec_for_this_source(dataspec)
    make_index_for_dataspec(current_source_dataspec)
    render current_source_dataspec
  end

  # Gets the dataspec object for this source
  def get_dataspec_for_this_source(dataspec_path)
    source_index = JSON.parse(File.read(dataspec_path+"dataset_details.json"))["Index Name"]
    return @dataspecs.select{ |d| d.index_name == source_index}.first
  end

  # Create all indexes
  def create_all_indexes
    load_everything
    @dataspecs.each do |dataspec|
      make_index_for_dataspec(dataspec)
    end

    respond_to do |format|
      format.json { head :ok }
    end
  end

  # Generates an index for this dataspec
  def make_index_for_dataspec(dataspec)
    doc_class = get_model(dataspec.index_name)
    client = doc_class.gateway.client
    if !client.indices.exists?(index: dataspec.index_name)
      IndexManager.create_index(dataspec, gen_class_name(dataspec))
    end
  end
end
