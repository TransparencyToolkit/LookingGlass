require 'pry'

module TagProcessor
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
