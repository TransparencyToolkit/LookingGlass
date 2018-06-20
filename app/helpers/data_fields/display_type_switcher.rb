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
    nonstandard_show_types = ["Category", "Attachment", "Link", "Named Link", "Child Document Link", "Related Link", "Source Link"]
    (action == "show") && !nonstandard_show_types.include?(type) ? (return "Show") : (return type)
  end

  # Check if there is data for a particular type of field
  def is_data_for_type?(type, doc, dataspec)
    fields_of_type = dataspec["source_fields"].select{|field, details| details["display_type"] == type }
    fields_of_type.each do |field|
      field_data = get_text(doc, field[0], field[1])
      return true if !field_data.empty?
    end
    return false
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
    when "Named Link"
      render partial: "docs/fields/named_links", locals: { data: field_data, human_readable: human_readable_name, field: field }
    when "Child Document Link"
      children = get_child_documents(doc, field)
      label = field_details["associated_doc_label"]
      render partial: "docs/fields/child_documents", locals: { data: children, human_readable: label, field: field }
    when "Related Link"
      render partial: "docs/fields/related_links", locals: { data: field_data, human_readable: human_readable_name, field: field }
    when "Source Link"
      render partial: "docs/fields/source_link", locals: { data: field_data, human_readable: human_readable_name, field: field }
    when "Attachment"
      return show_attachments_by_type(field_data)
    when "Show"
      render partial: "docs/fields/show_text", locals: { text: field_data, human_readable: human_readable_name, field: field }
    when "Category"
      facet_links = facet_links_for_results(doc, field, field_data)
      if action == "index"
        render partial: "docs/fields/tiny_text", locals: { icon: icon, text: facet_links, field: field }
      elsif action == "show"
        render partial: "docs/fields/show_facets", locals: { icon: icon, text: facet_links, field: field, human_readable: human_readable_name }
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

  # Get the type for a file path
  def get_file_type(file)
    if file.include?("documentcloud")
      return "doc_cloud"
    else
      return File.extname(URI.parse(URI.encode(file)).path)
    end
  end

  # Genearate a link to download the file
  def gen_download_link_name(file)
    # Get the human readable title for the document
    dataspec = get_dataspec_for_doc(@doc)
    title_field = dataspec["source_fields"].select{|field, details| details["display_type"] == "Title" }.keys.first
    doc_title = @doc["_source"][title_field]

    # Get the file name and combine them
    file_name = file.split("/").last
    return "#{doc_title} (#{file_name})"
  end

  # Switch between different attachment file types
  def attachment_file_format_switcher(file)
    file_type = get_file_type(file)
    download_name = gen_download_link_name(file)

    case file_type
    when ".jpg", ".jpeg", ".gif", ".png", ".bmp"
      render partial: "docs/fields/file_types/image", locals: { file: file, download_name: download_name }
    when ".pdf"
      render partial: "docs/fields/file_types/pdf", locals: { file: file, download_name: download_name }
    when "doc_cloud"
      render partial: "docs/fields/file_types/doc_cloud", locals: { file: file }
    when ".html", ".htm", ".txt", ".svg", ".mp4"
      render partial: "docs/fields/file_types/iframe", locals: { file: file, download_name: download_name }
    else
      render partial: "docs/fields/file_types/download", locals: { file: file, download_name: download_name }
    end
  end
end
