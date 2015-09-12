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
  
  # Puts results in appropriate order and handles item fields
  def order_results(docs)
    item_ids = []
    items = Hash.new
    
    docs.sort { |a, b| a["_score"] <=> b["_score"] }.reverse.each do |doc|
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
end
