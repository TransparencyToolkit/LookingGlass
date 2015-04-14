module DateParser
  # Process parameters for date query into form needed for build_search_query
  def process_date_params(fieldname, search_item)
    start_date_val = @params[search_item["Form Params"][0]]
    end_date_val = @params[search_item["Form Params"][1]]

    return {
      field: fieldname,
      start_date: start_date_val && !start_date_val.empty? ? parse_date(start_date_val) : "0001-01-01",
      end_date: end_date_val && !end_date_val.empty? ? parse_date(end_date_val) : Time.now
    }
  end

  # Convert date into appropriate format for elasticsearch
  def parse_date(date)
    parseddate = date.split("/")
    return "#{parseddate[2]}-#{parseddate[0]}-#{parseddate[1]}"
  end
end
