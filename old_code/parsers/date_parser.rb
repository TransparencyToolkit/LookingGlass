module DateParser
  # Process parameters for date query into form needed for build_search_query
  def process_date_params
    startrange, endrange, fieldname, dataspec = ""

    # Get the sart and end of range vals
    @params.each do |key, value|
      if key.include?("startrange_")
        startrange = @params[key]
        fieldname, dataspec = get_date_index(key)
      elsif key.include?("endrange_")
        endrange = @params[key]
        fieldname, dataspec = get_date_index(key)
      end
    end
   
    # Return dataspec and date info
    return dataspec, {
      field: fieldname,
      start_date: handle_empty_dates(startrange, "0001-01-01"),
      end_date: handle_empty_dates(endrange, Time.now)
    }
  end

  # Use default for empty dates
  def handle_empty_dates(date, default)
    date && !date.empty? ? parse_date(date) : default
  end

  # Convert date into appropriate format for elasticsearch
  def parse_date(date)
    parseddate = date.split("/")
    return "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"
  end
end
