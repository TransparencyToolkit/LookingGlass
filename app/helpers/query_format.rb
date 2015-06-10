module QueryFormat
  include GeneralUtils

  # Get all searchable fields
  def matchFieldTypes(match_type)
    outhtml = ""

    # Go through all searchable fields
    sortFields(@searchable_fields).each do |field|
      f = getFieldDetails(field)

      # If display type matches, add html
      if match_type.include?(f["Display Type"])
        outhtml += genOptionHtml(f)
      end
    end

    return outhtml
  end
  
  # Generate html for the matching option
  def genOptionHtml(f)
     return '<option data-type="' + f["Type"] + '"  value="' + f["Field Name"] + '">' + f["Human Readable Name"] + '</option>'
  end
end
