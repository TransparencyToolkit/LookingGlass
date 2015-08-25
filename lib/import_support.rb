module ImportSupport
  # Gets data from a link and imports it
  def importFromURL
    createFromFile(JSON.parse(URI.parse(@data_path).read, symbolize_names: true))
  end

  # Gets data from file and imports it
  def importFromFile
    createFromFile(JSON.parse(File.read(@data_path), symbolize_names: true))
  end

  # Handles the processing of each item in a file in a directory import
  def importFileInDir(file)
    # Get dataset name (file name) and categories (directory names)
    dataset_name = file.split("/").last.gsub("_", " ").gsub(".json", "")
    categories = file.gsub(@data_path, "").gsub(file.split("/").last, "").split("/").reject(&:empty?)
    categories.push(dataset_name)

    # Add the dataset_name and categories to each item, do any extra processing, then create
    count = 0
    # Handle null values instead of JSON
    file_text = File.read(file)
    file_items = JSON.parse(file_text) if file_text != "null"

    if file_items != nil && !file_items.empty?
      file_items.each do |i|
        i.merge!(dataset_name: dataset_name, categories: categories)
        createItem(processItem(i), dataset_name.gsub(" ", "")+count.to_s)
        count += 1
      end
    end
  end
end
