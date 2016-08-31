require 'pry'

module TagProcessor
  # Remove item or delete tags
  def process_tags_remove(item_content, dataspec, unique_id, doc_class)
    begin
      # Get the item
      id = getID(item_content, dataspec)
      item = doc_class.find(id)

      # Delete if last, otherwise remove tags and version
      if is_last?(item)
        delete_item(item, dataspec, doc_class)
      else
        remove_tags_from_item(item, doc_class, dataspec, item_content)
      end
    rescue
     
    end
  end

  # Check if the item is in more than one collection/selector
  def is_last?(item)
    if item.overall_tag.length > 1
      return false
    else
      return true
    end
  end

  # Take item as input and delete entirely
  def delete_item(item, dataspec, doc_class)
    client = doc_class.gateway.client
    client.delete index: dataspec.index_name, id: item["_id"], type: item["_type"]
  end

  # Remove tags from item and remove from versions
  def remove_tags_from_item(item, doc_class, dataspec, item_content)
    client = doc_class.gateway.client
    
    # Update overall tag
    item.overall_tag = item.overall_tag - [item_content["overall_tag"]]
    item.overall_tag_facet = item.overall_tag - [item_content["overall_tag"]]

    # Update search_terms
    if item.search_terms.length > 1
      item.search_terms = item.search_terms - [item_content["search_terms"]]
      item.search_terms_facet = item.search_terms - [item_content["search_terms"]]
    end

    # Update dataset name
    if item.dataset_name.length > 1
      item.dataset_name = item.dataset_name - [item_content["dataset_name"]]
      item.dataset_name_facet = item.dataset_name - [item_content["dataset_name"]]
    end

    # Remove from versions
    item.versions = item.versions.select{|i| i["overall_tag"].first != item_content["overall_tag"]}

    # Update item
    client.update index: dataspec.index_name, id: item["_id"], type: item["_type"], body: {doc: {
                                                                                           overall_tag: item.overall_tag,
                                                                                           overall_tag_facet: item.overall_tag_facet,
                                                                                           search_terms: item.search_terms,
                                                                                           search_terms_facet: item.search_terms_facet,
                                                                                           dataset_name: item.dataset_name,
                                                                                           dataset_name_facet: item.dataset_name_facet,
                                                                                           versions: item.versions}}
  end
  
  def process_tags_add(item_content, dataspec, unique_id, doc_class)
    item = check_if_exists(item_content, dataspec, doc_class)

    # Add tags to item if it already exists
    if item
      add_tags_to_item(item, item_content, dataspec, doc_class)
    else # Create new item
      create_with_tags(item_content, dataspec, doc_class)
    end
  end
  
  # Check if item already exists with ID
  def check_if_exists(item_content, dataspec, doc_class)
    begin
      # Find the item
      id = getID(item_content, dataspec)
      item = doc_class.find(id)
      return item # if exists
    rescue # In case it doesn't exist
      return false
    end
  end

  # Create a new item with tags
  def create_with_tags(item_content, dataspec, doc_class)
    item_content = make_tags_arrays(item_content)

    # Process and create item
    id = getID(item_content, dataspec)
    create_new(processItem(item_content, dataspec), dataspec, doc_class, id)
  end

  # Turn search_terms, dataset, and overall tags into arrays
  def make_tags_arrays(item_content)
    item_content["search_terms"] = [item_content["search_terms"]]
    item_content["dataset_name"] = [item_content["dataset_name"]]
    item_content["overall_tag"] = [item_content["overall_tag"]]
    return item_content
  end

  # Update an existing item with new tags
  def add_tags_to_item(item, item_content, dataspec, doc_class)
    # Add tags
    item_content = make_tags_arrays(item_content)

    # Create new version
    add_new_version(processItem(item_content, dataspec), dataspec, doc_class, getID(item_content, dataspec))
  end
end
