require 'index_manager.rb'

module DateFuncs
  # Checks if item is a date
  def isDate?(field)
    datefields = @field_info.select{ |item| item["Type"] == "Date" }

    datefields.each do |f|
      return true if f["Field Name"] == field
    end

    return false
  end

  # Set date field name as symbol or string as needed
  def set_name(f, item)
    date_field = f["Field Name"].to_sym
    date_field = item[date_field] == nil ? date_field.to_s : date_field
    return date_field
  end

  # Blanks the date field if it matches specified terms
  def blank_if_match(f, item, date_field, terms)
    terms.each do |t|
      item[date_field] = "" if item[date_field].to_s.include?(t)
    end

    return item
  end

  # Normalize unknown dates
  def handle_unknown_dates(f, item, date_field)
    # List of unknown date options
    unknown = ["Date unknown", "Unknown", "nodate", "0000-00-00 00:00:00"]

    # Check against unknown options
    item = blank_if_match(f, item, date_field, unknown)
    
    # Handle blank dates
    item[date_field] = "" if item[date_field].empty?
    return item
  end

  # Handle present dates
  def handle_present_dates(f, item, date_field)
    # List of words for present
    present = ["Present", "Current", "Gegenwart"]

    # Blank present dates
    return blank_if_match(f, item, date_field, present)
  end


  # Handle year only dates
  def handle_year_only(f, item, date_field)
    if item[date_field].to_s.length == 4 || item[date_field].to_s.length == 5
      item[date_field] = Date.parse("January " + item[date_field].to_s)
    end

    return item
  end
  
  # Handle foreign dates
  def handle_foreign_dates(f, item, date_field)
    if !item[date_field].to_s.empty?
      former_date = item[date_field]
      item[date_field] = Date.parse(normalize_date(item[date_field]).to_s)
    end

    return item
  end

  # Processes dates and handles unknowns
  def process_date(f, item)
    if f["Type"] == "Date"
      # Set date field to symbol or string as needed
      date_field = set_name(f, item)
      
      # Handle unknown and present dates
      handle_unknown_dates(f, item, date_field)
      handle_present_dates(f, item, date_field)

      # Handle dates that are parsed correctly
      begin
        item[date_field] = Date.parse(item[date_field])
      rescue # Handle dates that aren't parsed correctly
        item = handle_year_only(f, item, date_field)
        item = handle_foreign_dates(f, item, date_field)
      end
    end
    return item
  end
  
      
  # Normalizes dates in other languages
  def normalize_date(date)
    # Load in file
    package_path = "data_packages/month-names/"
    package = DataPackage::Package.new(package_path+"datapackage.json")
    file = CSV.parse(File.read(package_path+package.resources[0]["path"]))

    # Check for matches in all value rows
    file.each_with_index do |row, index|
      if index != 0
        row.each_with_index do |item, i_index|

          # Check all other language row items to see if it is included
          if i_index != 0 && date.to_s.include?(item)
            return date.sub(item, row[0])
          end

        end
      end
    end

    # Return input if it gets this far
    return date
  end
end
