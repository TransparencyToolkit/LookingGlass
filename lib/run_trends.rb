require 'open-uri'
require 'pry'
require 'datapackage.rb'
load 'generate_id.rb'
load 'date_funcs.rb'
load 'misc_process.rb'
load 'process_data.rb'
load 'import_support.rb'
load 'multi_dataset.rb'
load 'version_tracking.rb'
load '/home/shidash/Data/ICWATCH-Data/analyze/timeline.rb'

class RunTrends
  extend GenerateId
  extend DateFuncs
  extend MiscProcess
  extend ProcessData
  extend ImportSupport
  extend MultiDataset
  extend ClassGen
  extend FacetsQuery
  extend VersionTracking

  # Run a timeline trend
  def self.run_timeline_trend(dataset, chosen_model)
    t = Timeline.new(dataset[:ignore_incl], dataset[:search_word_list], dataset[:date_field], dataset[:id_field], dataset[:extract_field], dataset[:case_sensitive], dataset[:individual_stats])
    
    # Run query for each term
    dataset[:search_word_list].each do |term|
      #binding.pry
      query = {:from=>0,
      :size=>999999,
      :query=>
      {:simple_query_string=>
       {:query=>term,
        :fields=>@all_searchable_fields,
        :default_operator=>"AND",
        :flags=>"AND|OR|PHRASE|PREFIX|NOT|FUZZY|SLOP|NEAR"}}}

     # binding.pry
      docs = Elasticsearch::Model.search(query, chosen_model).response.hits.hits
      
      # Loop through results
      docs.each do |item|
        t.processItem(item["_source"].to_hash, term)
      end
    end
    
    # Process each item
    #item_loop(chosen_model) do |item|
    #  begin
      #binding.pry if item.to_hash["full_name"].include?("Tristan Wyatt")
    #  t.processItem(item.to_hash)
    #  rescue
       # binding.pry
    #  end
   # end
    
    # Return output
    if dataset[:output_format] == "split"
      return t.format_output_split
    elsif dataset[:output_format] == "with_id"
      return t.output_keep_id
    end
  end

  # Loop through items and run block
  def self.item_loop(chosen_model, &block)
    total = chosen_model.count
    from = 0

    while from < (total+1000)
      cur_docs = Elasticsearch::Model.search({from: from, size: 1000, facets: @all_facets}, [chosen_model]).response.hits.hits
      from += 1000
      # Nil line 30 error
      
      cur_docs.each do |item|
        yield(item.to_hash["_source"])
      end
    end
  end

  def self.get_all_with_term(dataset, term)
    # Load things in
    load_everything
    chosen_model = get_model(dataset[:index])
  end
  
  def self.get_all_of_type(dataset)
    # Load things in
    load_everything
    chosen_model = get_model(dataset[:index])
    
    # Run trend specified
    if dataset[:trend_type] == "timeline"
      trend_results = run_timeline_trend(dataset, chosen_model)
    end  
      
    # Write results to file
    trend_path = Dir.pwd+"/lib/trends/"+dataset[:index]+"_"+dataset[:trend_name]+".json"
    File.write(trend_path, trend_results)
  end
end
