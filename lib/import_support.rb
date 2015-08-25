module ImportSupport
  # Gets data from a link and imports it
  def importFromURL
    createFromFile(JSON.parse(URI.parse(@data_path).read, symbolize_names: true))
  end

  # Gets data from file and imports it
  def importFromFile
    createFromFile(JSON.parse(File.read(@data_path), symbolize_names: true))
  end

  
  # Get dataset name (file name) - for import from dir
  def getDatasetName(file)
    return file.split("/").last.gsub("_", " ").gsub(".json", "")
  end

  # Get categories (dir name) - for import from dir
  def getNameCategories(file, dataset_name)
    categories = file.gsub(@data_path, "").gsub(file.split("/").last, "").split("/").reject(&:empty?)
    categories.push(dataset_name)
    return categories
  end

  # Open file for dir import (if not null)
  def openFile(file)
    file_text = File.read(file)
    return JSON.parse(file_text) if file_text != "null"
  end

  # Append categories to file items and create
  def appendCategories(file_items, dataset_name, categories)
    count = 0

    # Loop through all items if not nill or empty
    if file_items != nil && !file_items.empty?
      file_items.each do |i|
        i.merge!(dataset_name: dataset_name, categories: categories)
        createItem(processItem(i), dataset_name.gsub(" ", "")+count.to_s)
        count += 1
      end
    end
  end
  
  # Handles the processing of each item in a file in a directory import
  def importFileInDir(file)
    # Get dataset name and categories
    dataset_name = getDatasetName(file)
    categories = getNameCategories(file, dataset_name)

    # Append categories to items and create
    appendCategories(openFile(file), dataset_name, categories)    
  end
end
