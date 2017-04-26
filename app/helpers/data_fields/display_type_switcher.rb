# A helper that formats fields for display by display type
module DisplayTypeSwitcher
  # Get all the fields in the document of a certain type, process them, add output together
  def show_by_type(type, doc, dataspec, action="index")
    # Get all the fields matching the particular type
    fields_of_type = dataspec["source_fields"].select{|field, details| details["display_type"] == type }
    type = update_type_for_action(action, type)
    
    # Render all fields of the type
    return fields_of_type.inject("") do |str, field|
      str += type_switcher(type, doc, field[0], field[1], action)
      raw(str)
    end
  end

  # Handle some show view fields differently than index fields
  def update_type_for_action(action, type)
    nonstandard_show_types = ["Category", "Attachment", "Link"]
    (action == "show") && !nonstandard_show_types.include?(type) ? (return "Show") : (return type)
  end
 
  # Switch between display types
  def type_switcher(type, doc, field, field_details, action)
    # Get data needed to render fields
    field_data = get_text(doc, field, field_details)
    human_readable_name = human_readable_title(field_details)
    icon = icon_name(field_details)

    # Switch by field type
    case type
    when "Title"
      render partial: "docs/fields/title", locals: { doc_title: field_data, doc: doc }
    when "Picture"
      render partial: "docs/fields/picture", locals: { pic_path: field_data }
    when "Short Text", "Description"
      render partial: "docs/fields/short_text", locals: { text: field_data }
    when "Shorter Text", "Tiny Text"
      render partial: "docs/fields/tiny_text", locals: { icon: icon, text: field_data, field: field }
    when "Long Text"
      render partial: "docs/fields/long_text", locals: { text: field_data }
    when "Date", "DateTime", "Number"
      render partial: "docs/fields/date", locals: { date: field_data, human_readable: human_readable_name }
    when "Link"
      render partial: "docs/fields/links", locals: { links: field_data }
    when "Attachment"
      return show_attachments_by_type(field_data)
    when "Show"
      render partial: "docs/fields/show_text", locals: { text: field_data, human_readable: human_readable_name, field: field }
    when "Category" 
      facet_links = facet_links_for_results(doc, field, field_data)
      if action == "index"
        render partial: "docs/fields/tiny_text", locals: {icon: icon, text: facet_links, field: field}
      elsif action == "show"
        render partial: "docs/fields/show_facets", locals: {icon: icon, text: facet_links,
                                                            field: field, human_readable: human_readable_name}
      end
    end
  end


  # Go through files and show
  def show_attachments_by_type(files)
    files = files.is_a?(Array) ? files : [files]

    # Go through all files and output display
    return files.inject("") do |str, file|
      str += attachment_file_format_switcher(file)
      raw(str)
    end
  end
  
  # Switch between different attachment file types
  def attachment_file_format_switcher(file)
    file_type = File.extname(URI.parse(URI.encode(file)).path)

    case file_type
    when ".jpg", ".jpeg", ".gif", ".png", ".bmp", ".tif", ".tiff"
      render partial: "docs/fields/file_types/image", locals: { file: file }
    when ".pdf"
      render partial: "docs/fields/file_types/pdf", locals: { file: file }
    else
      render partial: "docs/fields/file_types/download", locals: { file: file }  
    end
  end
end
