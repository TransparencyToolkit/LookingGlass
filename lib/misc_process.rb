module MiscProcess
  # Generates properly formatted class name
  def gen_class_name(dataspec)
    return dataspec.index_name.split("_").map{ |c| c.capitalize}.join+"Doc"
  end
  
  # Adds the specified prefix to the images
  def process_pic(f, item, dataspec)
    if f["Field Name"] == "picture"
      pic_field = f["Field Name"]

      if !dataspec.image_prefix.empty?
        item[pic_field] = dataspec.image_prefix+item[pic_field].split("/").last
      end
    end

    return item
  end

  # Creates a facet version with the same value for field
  def make_facet_version(f, item, dataspec)
    if dataspec.facet_fields.include?(f["Field Name"])
      field_name = f["Field Name"]
      facet_field_name = f["Field Name"]+"_facet"

      item[facet_field_name.to_sym] = item[set_name(field_name, item)]
    end
    
    return item
  end

  # Set field name as symbol or string as needed
  def set_name(f, item)
    field_name = f.to_sym
    field_name = item[field_name] == nil ? field_name.to_s : field_name
    return field_name
  end
end
