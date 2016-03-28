load 'lib/index_manager.rb'

class IndexController < ApplicationController
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
  end

  # Gets the dataspec object for this source
  def get_dataspec_for_this_source(dataspec_path)
    source_index = JSON.parse(File.read(dataspec_path+"dataset_details.json"))["Index Name"]
    return @dataspecs.select{ |d| d.index_name == source_index}.first
  end

  # Generates an index for this dataspec
  def make_index_for_dataspec(dataspec)
    IndexManager.create_index(dataspec, gen_class_name(dataspec), force: true)
  end
end
