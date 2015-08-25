module MiscProcess
  # Adds the specified prefix to the images
  def process_pic(f, item)
    if f["Field Name"] == "picture"
      pic_field = f["Field Name"]

      if !@image_prefix.empty?
        item[pic_field] = @image_prefix+item[pic_field].split("/").last
      end
    end

    return item
  end


  # Creates a facet version with the same value for field
  def make_facet_version(f, item)
    if @facet_fields.include?(f["Field Name"])
      field_name = f["Field Name"]
      facet_field_name = f["Field Name"]+"_analyzed"

      item[facet_field_name.to_sym] = item[field_name.to_sym]
    end

    return item
  end
end
