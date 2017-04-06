# A helper that formats fields for display by display type
module DisplayTypeSwitcher
  # Get all the fields in the document of a certain type, process them, add output together
  def show_by_type(type, doc, dataspec)
    # Get all the fields matching the particular type
    fields_of_type = dataspec["source_fields"].select{|field, details| details["display_type"] == type }

    # Render all fields of the type
    return fields_of_type.inject("") do |str, field|
      str += type_switcher(type, doc, field[0], field[1])
      raw(str)
    end
  end
 
  # Switch between display types
  def type_switcher(type, doc, field, field_details)
    # Get data needed to render fields
    field_data = get_text(doc, field)
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
    when "Category"
      facet_links = list_of_facet_links(doc, field, field_data)
      render partial: "docs/fields/tiny_text", locals: {icon: icon, text: facet_links, field: field}
    end
  end
end
