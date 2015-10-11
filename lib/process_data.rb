module ProcessData
  # Processes and creates items in single file
  def createFromFile(data, dataspec)
    unique_id = 0
    data.each do |item|
      createItem(processItem(item, dataspec), unique_id)
      unique_id += 1
    end
  end

  # Preprocesses documents for loading into ES
  def processItem(item, dataspec)
    # Go through each field in item
    dataspec.field_info.each do |f|
      item = process_date(f, item)
      item = process_pic(f, item, dataspec)
      item = make_facet_version(f, item, dataspec)
    end
    
    return item
  end

  # Creates a new item in the index
  def createItem(item, unique_id, dataspec, doc_class)
    begin
      if deduplicate(item, dataspec, doc_class)
        doc_class.create item.merge(id: getID(item, dataspec)), index: dataspec.index_name
      end
    rescue
      doc_class.create item.merge(id: getID(item, dataspec)), index: dataspec.index_name
    end
  end
end
