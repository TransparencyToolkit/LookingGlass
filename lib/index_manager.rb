require 'open-uri'
require 'pry'
load 'index_methods.rb'

class IndexManager
  extend IndexMethods
  include ENAnalyzer

  # Index creation
  def self.create_index(options={})
    # Make client, get settings, set name
    client = Doc.gateway.client
    
    loadDataspec
    Doc.index_name = @index_name
    
    # Delete index if it already exists
    client.indices.delete index: @index_name rescue nil if options[:force]
    
    settings = ENAnalyzer.analyzerSettings
    mappings = Doc.mappings.to_hash
    
    # Create index with appropriate settings and mappings
    client.indices.create index: @index_name,
    body: {
      settings: settings.to_hash,
      mappings: mappings.to_hash }
  end

  # Import data from different formats
  def self.import_data(options={})
    create_index force: true if options[:force]

    # Import from file, link, or dir
    case @data_path_type
    when "File"
      importFromFile
    when "url"
      importFromURL
    when "Directory"
      Dir.glob(@data_path+"/**/*.json") do |file|
        if !file.include? @ignore_ext
          importFileInDir(file)
        end
      end
    end
  end

  # Gets data from a link and imports it
  def self.importFromURL
    createFromFile(JSON.parse(URI.parse(@data_path).read, symbolize_names: true))
  end

  # Gets data from file and imports it
  def self.importFromFile
    createFromFile(JSON.parse(File.read(@data_path), symbolize_names: true))  
  end

  # Processes and creates items in single file
  def self.createFromFile(data)
    unique_id = 0
    data.each do |item|
      createItem(processItem(item), unique_id)
      unique_id += 1
    end
  end

  # Preprocesses documents for loading into ES
  def self.processItem(item)
    # Go through each field in item
    @field_info.each do |f|
      item = process_date(f, item)
      item = process_pic(f, item)
      item = make_facet_version(f, item)
    end

    return item
  end

  # Creates a new item in the index
  def self.createItem(item, unique_id)
    begin
      if deduplicate(item)
        Doc.create item.merge(id: getID(item)), index: @index_name
      end
    rescue
      Doc.create item.merge(id: getID(item)), index: @index_name
    end
  end

  # Deduplicate Items
  def self.deduplicate(item)
    # Check if any item from same profile has been added
    potential_dups = Doc.search(query: { match: { @id_field => item[@id_field] }}).results
    
    # Check if there are any entries for that item
    if !potential_dups.empty?
      potential_dups.each do |dup_i|
        # See if it is exact match or not
        if exactMatch?(removeIgnore(item).symbolize_keys, removeIgnore(dup_i.to_hash))
          # Check if matching item was scraped after saved item
          if Date.parse(item[@dedup_prioritize]) > Date.parse(dup_i[@dedup_prioritize].to_s)
            return true # TODO: Delete the old item and create a new one instead
          else
            return false # Existing item is more recent
          end
        else
          return true # A different entry for same item
        end
      end
    else
      return true # No other entries for item
    end
  end

  # See if all the fields in first item match all the fiels in the second item
  def self.exactMatch?(first_item, second_item)
    first_item.each do |key, value|
      # Checks if it is a date, not nil, and not a year
      if second_item[key]
        if isDate?(key.to_s) && value != nil && value.length > 4
         # Sometimes end dates are different for same position- this is a bug
        elsif value == nil
          return false if !second_item[key] == nil
        elsif value.is_a?(Integer) || value.is_a?(Float)
          return false if value.to_i != second_item[key].to_i
        elsif !value.is_a?(Integer) && value.empty?
          return false if value.empty? && (second_item[key] != nil && !second_item[key].empty?)
        elsif second_item[key] != value
          return false
        end
      end
    end
        return true
    
  end
  # Checks if item is a date
  def self.isDate?(field)
    datefields = @field_info.select{ |item| item["Type"] == "Date" }
    
    datefields.each do |f|
      return true if f["Field Name"] == field
    end
    
    return false
  end
  
  # Remove ignore fields
  def self.removeIgnore(item)
    itemcopy = item.dup
    @dedup_ignore.each do |remove|
      itemcopy = itemcopy.except(remove, remove.to_sym)
    end
    
    return itemcopy    
  end

  # Get unique ID
  def self.getID(item)
    # If some part should be removed from the ID field
    if @get_after != nil && !@get_after.empty?
      clean_id = cleanID(item[@id_field.to_sym].split(@get_after)[1])
    else
      clean_id = cleanID(item[@id_field.to_sym])
    end

    @id_secondary.each do |f|
      clean_id += cleanID(item[f.to_sym]) if item[f.to_sym] != nil
    end
    
    return clean_id
  end

  # Removes non-urlsafe chars from ID
  def self.cleanID(str)
    if str
      return str.gsub("/", "").gsub(" ", "").gsub(",", "").gsub(":", "").gsub(";", "").gsub("'", "").gsub(".", "")
    end
  end
  
  # Handles the processing of each item in a file in a directory import
  def self.importFileInDir(file)
    # Get dataset name (file name) and categories (directory names)
    dataset_name = file.split("/").last.gsub("_", " ").gsub(".json", "")
    categories = file.gsub(@data_path, "").gsub(file.split("/").last, "").split("/").reject(&:empty?)
    categories.push(dataset_name)
    
    # Add the dataset_name and categories to each item, do any extra processing, then create
    count = 0
    file_items = JSON.parse(File.read(file))
    file_items.each do |i|
      i.merge!(dataset_name: dataset_name, categories: categories)
      createItem(processItem(i), dataset_name.gsub(" ", "")+count.to_s)
      count += 1
    end
  end

  # Processes dates and handles unknowns
  def self.process_date(f, item)
    if f["Type"] == "Date"
      date_field = f["Field Name"].to_sym
      
      # Normalize unknown vals
      if item[date_field] == "Date unknown" || item[date_field] == "Unknown"
        item[date_field] = nil
      end
    end

    return item
  end

  # Makes links https
  def self.process_pic(f, item)
    if f["Field Name"] == "picture"
      pic_field = f["Field Name"]

      if !item[pic_field].include?("https://")
        item[pic_field] = item[pic_field].gsub!("http://m.c.lnkd", "https://media")
      end
    end

    return item
  end
  
  
  # Creates a facet version with the same value for field
  def self.make_facet_version(f, item)
    if @facet_fields.include?(f["Field Name"])
      field_name = f["Field Name"]
      facet_field_name = f["Field Name"]+"_analyzed"

      item[facet_field_name.to_sym] = item[field_name.to_sym]
    end

    return item
  end
end

