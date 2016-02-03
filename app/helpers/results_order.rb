module ResultsOrder
  # Gets the ID field for the item based on the dataspec
  def get_id(doc, dataspec)
    id_field = dataspec.id_field
    return getText(doc, id_field, doc)
  end

  # Groups item fields by ID
  def gen_unique_results(doc, items, item_ids, uid, item_fields)
    if item_ids.include?(uid) # If item with same ID is included already
      items[uid]["item_fields"].to_a.push(list_item_info(item_fields, doc))
    else # If item with same ID has not been added yet
      items = add_first_for_id(items, uid, doc, item_fields)
      item_ids.to_a.push(uid)
    end

    return items, item_ids
  end

  # Adds item and first set of item fields
  def add_first_for_id(items, uid, item, item_fields)
    items[uid] = item
    items[uid]["item_fields"] = [list_item_info(item_fields, item)]
    return items
  end

  # Generates a list of item fields and vals
  def list_item_info(item_fields, item)
    return item_fields.inject({}) do |item_info, field|
      item_info[field] = item["_source"][field]
      item_info
    end
  end

  # Gets the dataspec, id, and item_fields
  def get_details(doc)
    dataspec = get_dataspec(doc)
    uid = get_id(doc, dataspec)
    item_fields = dataspec.item_fields

    return dataspec, uid, item_fields
  end

  # Return hash of arrays of docs separated by type
  def separate_docs_by_type(docs)
    doc_lists = Hash.new

    # Check the dataspec for each document
    docs.each do |doc|
      dataspec = get_dataspec(doc)

      # Add to array of docs or make new array
      if doc_lists[dataspec]
        doc_lists[dataspec].push(doc)
      else
        doc_lists[dataspec] = [doc]
      end
    end

    return doc_lists
  end

  # Sorts the documents
  def sort_docs(docs, sort_field)
    item_ids = []
    items = Hash.new

    docs.sort { |a, b| a[sort_field] <=> b[sort_field] }.each do |doc|
      # Get the dataspec, id, item_fields
      dataspec, uid, item_fields = get_details(doc)

      # Handle differently for item_fields vs none
      if item_fields
        items, item_ids = gen_unique_results(doc, items, item_ids, uid, item_fields)
      else
        items[uid] = doc
      end
    end

    return items
  end
  
  # Puts results in appropriate order and handles item fields
  def order_results(docs)
    ordered_results = Hash.new

    # Sort by score if there is a score field, otherwise sort by sort field
    if !docs.empty?
      if docs.first["_score"]
        ordered_results.merge!(sort_docs(docs, "_score").to_a.reverse.to_h)
      else
        separate_docs_by_type(docs).each do |key, value|
          ordered_results.merge!(sort_docs(value, key.sort_field))
        end
      end
    end

    return ordered_results
  end
end
