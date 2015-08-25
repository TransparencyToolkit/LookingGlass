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

  # Processes dates and handles unknowns
  def process_date(f, item)
    if f["Type"] == "Date"
      # Set date field to symbol or string as needed
      date_field = f["Field Name"].to_sym
      date_field = item[date_field] == nil ? date_field.to_s : date_field

      # Normalize unknown vals
      if item[date_field] == "Date unknown" || item[date_field] == "Unknown" || item[date_field] == "nodate" || item[date_field].to_s == "0000-00-00 00:00:00" || item[date_field].empty?
        item[date_field] = ""

        # Normalize present vals for end dates
      elsif item[date_field].include?("Present") || item[date_field].include?("Current") || item[date_field].include?("Gegenwart")
        item[date_field] = ""
      end

      # Handle dates that aren't parsed correctly
      begin
        item[date_field] = Date.parse(item[date_field])
      rescue
        # Handle year only dates
        if item[date_field].to_s.length == 4 || item[date_field].to_s.length == 5
          item[date_field] = Date.parse("January " + item[date_field].to_s)
        elsif !item[date_field].empty? # Handle foreign dates
          former_date = item[date_field]
          item[date_field] = Date.parse(normalize_date(item[date_field]).to_s)
        end
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
          if i_index != 0 && date.include?(item)
            return date.sub(item, row[0])
          end

        end
      end
    end

    # Return input if it gets this far
    return date
  end
end
