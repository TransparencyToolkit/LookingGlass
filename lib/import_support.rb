module ImportSupport
  # Get dataset name (file name) - for import from dir
  def getDatasetName(file)
    return file.split("/").last.gsub("_", " ").gsub(".json", "")
  end

  # Get categories (dir name) - for import from dir
  def getNameCategories(file, dataset_name, dataspec)
    categories = file.gsub(dataspec.data_path, "").gsub(file.split("/").last, "").split("/").reject(&:empty?)
    categories.push(dataset_name)
    return categories
  end

  # Open file for dir import (if not null)
  def openFile(file)
    file_text = File.read(file)
    return JSON.parse(file_text) if file_text != "null"
  end

  # Append fields and create item
  def append_and_create_item(i, dataset_name, categories, dataspec, doc_class)
    i.merge!(dataset_name: dataset_name, categories: categories)
    i.merge!(data_source: getDatasource(dataspec, i)) if @importer.first[1].size >1
    createItem(processItem(i, dataspec), dataset_name.gsub(" ", "")+count.to_s, dataspec, doc_class)
    count += 1
  end

  # Append categories to file items and create
  def appendCategories(file_items, dataset_name, categories, dataspec, doc_class)
    count = 0
    
    # Loop through all items if not nill or empty
    if file_items != nil && !file_items.empty?

      # Check if it is hash or array to determine handling
      if file_items.is_a?(Hash)
        append_and_create_item(file_items, dataset_name, categories, dataspec, doc_class)
      elsif fil_items.is_a?(Array)
        file_items.each do |i|
          append_and_create_item(i, dataset_name, categories, dataspec, doc_class)
        end
      end
    end
  end

  # Append dataspec if importer greater than two
  def getDatasource(dataspec, i)
    return dataspec.index_name.gsub("_", " ").capitalize
  end

  # Handles the processing of each item in a file in a directory import
  def importFileInDir(file, dataspec, doc_class)
    # Get dataset name and categories
    dataset_name = getDatasetName(file)
    categories = getNameCategories(file, dataset_name, dataspec)

    # Append categories to items and create
    appendCategories(openFile(file), dataset_name, categories, dataspec, doc_class)
  end
end
