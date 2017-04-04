# A helper that formats fields for display by display type
module DisplayFields
  # Get all the fields in the document of a certain type, process them, add output together
  def show_by_type(type, doc, dataspec)
    # Get all the fields matching the particular type
    fields_of_type = dataspec["source_fields"].select{|field, details| details["display_type"] == type }

    # Generate the output by parsing each type
    output = fields_of_type.inject("") do |str, field|
      str += type_switcher(type, doc, field[0], field[1]).to_s
      str
    end
    
    return raw(output)
  end
 
  # Switch between display types
  def type_switcher(type, doc, field, field_details)
    case type
    when "Title"
      return display_title(doc, field)
    when "Picture"
      return display_picture(doc, field)
    when "Short Text", "Description"
      return display_short_text(doc, field)
    when "Shorter Text", "Tiny Text"
      return display_tiny_text(doc, field, field_details)
    when "Long Text"
      return display_long_text(doc, field)
    when "Date", "DateTime", "Number"
      return display_date(doc, field, field_details)
    when "Category"
      return display_category(doc, field, field_details)
    end
  end

  # Gets text for the field
  def get_text(doc, field)
    if is_highlighted?(doc, field)
      return raw(doc["highlight"][field].first.to_s)
    else
      return doc["_source"][field]
    end
  end

  # Checks if field is highlighted in restuls
  def is_highlighted?(doc, field)
    return doc["highlight"] && doc["highlight"][field] && !doc["highlight"][field].empty?
  end

  # Gets list of the highlighted categories
  def get_highlighted_categories(doc, fieldname)
    highlightlist = Hash.new

    if is_highlighted?(doc, fieldname)
      doc["highlight"][fieldname].each do |field|
        highlightlist[ActionView::Base.full_sanitizer.sanitize(field)] = field
      end
    end

    return highlightlist
  end

  # Display title fields correctly
  def display_title(doc, field)
    # Get the text to the field
    doc_title = get_text(doc, field)
    doc_title = "(No Title)" if (!doc_title || doc_title.empty?)

    # Return link to doc
    return link_to(doc_title, doc_path(doc["_id"]), class: "list_title", target: "_blank")
  end

  # Format the icon for viewing
  def display_icon(dataspec)
    datasource = dataspec["name"]
    icon_name = "icon-"+datasource.downcase.gsub("/", "-").gsub(" ", "-")

    return "<i class='"+icon_name+"'></i> "+datasource
  end

  # Display picture for the document
  def display_picture(doc, field)
    picture_path = doc["_source"][field]
    return '<img src="'+picture_path+'" class="picture"></img>' if picture_path
  end

  # Prepares description/short text view
  def display_short_text(doc, field)
    text = get_text(doc, field)
    text = text.join(", ") if text.is_a?(Array)
    return text
  end

  # Prepares longer text view
  def display_long_text(doc, field)
    return truncate(get_text(doc, field), length: 200)
  end

  # Generate shorter text
  def display_tiny_text(doc, field, field_details)
    text = display_short_text(doc, field)
    if text
      return create_facet_field(field_details, field, text)
    end
  end

  # Display the category
  def display_category(doc, field, field_details)
    # Get list of categories that are highlighted (and highlighted section)
    highlighted_categories = get_highlighted_categories(doc, field)

    # Gen all links
    facet_links = generate_facet_links(doc["_source"][field], field, highlighted_categories)
    
    # Generate full field with all links
    output = ""
    if facet_links != "" && !facet_links.empty?
      output += create_facet_field(field_details, field, facet_links)
    end

    return output
  end

  # Generate the rest of the facet field
  def create_facet_field(field_details, field, facet_links)
    facet_icon = field_details["Icon"].to_s
    return '<div class="facet '+field+' "><i class="icon-'+facet_icon+ '"></i> ' + facet_links +' </div>'
  end

  # Generates links to data filtered by facet val
  def generate_facet_links(field_vals, field_name, highlighted_categories)
    outstr = ""

    # Generate links for each value in list of facet vals
    if field_vals.is_a?(Array)
      field_vals.each do |i|
        begin
          outstr += create_link_for_single_facet(i, field_name, highlighted_categories)
          outstr += ", " if i != field_vals.last
        rescue
        end
      end
      # For single values
    else
      if field_vals
        outstr += create_link_for_single_facet(field_vals, field_name, highlighted_categories)
      end
    end
    return outstr
  end

  # Generate facet link for category results
  def create_link_for_single_facet(field_vals, field_name, highlighted_categories)
    begin
      # Bold category name if highlighted
      facet_name = highlighted_categories[field_vals] ? raw(highlighted_categories[field_vals]) : field_vals.strip

      # Return link
      return link_to(facet_name, search_path((field_name+"_facet").to_sym => field_vals))
    rescue
    end
  end

  # Prepares date view
  def display_date(doc, field, field_details)
    human_readable = field_details["human_readable"]
    date = doc["_source"][field]
    return '<span class="date">'+human_readable+ ': <span class="list_date">'+date.to_s+'</span></span>'
  end
end
