module ProcessData
  # Processes and creates items in single file
  def createFromFile(data)
    unique_id = 0
    data.each do |item|
      createItem(processItem(item), unique_id)
      unique_id += 1
    end
  end

  # Preprocesses documents for loading into ES
  def processItem(item)
    # Go through each field in item
    @field_info.each do |f|
      item = process_date(f, item)
      item = process_pic(f, item)
      item = make_facet_version(f, item)
    end

    return item
  end

  # Creates a new item in the index
  def createItem(item, unique_id)
    begin
      if deduplicate(item)
        Doc.create item.merge(id: getID(item)), index: @index_name
      end
    rescue
      Doc.create item.merge(id: getID(item)), index: @index_name
    end
  end
end
