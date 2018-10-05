module DataspecFilter

    # Returns a list of document types for instance with classnames and human
    # readable names
    def document_type_list
        datasources = get_dataspecs_for_project(ENV['PROJECT_INDEX'])

        return datasources.map{|d| [d["class_name"], d["name"]]}.to_h
    end

    # Filters for display types given in an array
    def filter_field_display_type(display_types, list_fields)
        filtered = list_fields.select{|f, v| display_types.include?(v["display_type"])}
        return format_fields(filtered)
    end

    # Returns all date fields in document
    def list_date_fields_by_document_type(doc_type)
        return filter_field_display_type(["Date", "DateTime"], list_raw_fields_by_document_type(doc_type))
    end

    # Returns a list of all text fields in the document
    def list_text_fields_by_document_type(doc_type)
        text_types = ["Category", "Title", "Description", "Long Text",
                      "Short Text", "Shorter Text", "Tiny Text"]
        return filter_field_display_type(text_types, list_raw_fields_by_document_type(doc_type))
    end

    # Returns a formatted list of fields given a document type
    def list_all_fields_by_document_type(doc_type)
      unformatted_fields = list_raw_fields_by_document_type(doc_type)
      return format_fields(unformatted_fields)
    end

    # Formats the fields to only return the classname and human readable name
    def format_fields(field_list)
        return field_list.to_a.map{|f| [f[0], f[1]["human_readable"]]}.to_h
    end

    # Returns a list of all fields given a document type
    def list_raw_fields_by_document_type(doc_type)
        datasources = get_dataspecs_for_project(ENV['PROJECT_INDEX'])
        spec_for_type = datasources.select{|d| d["class_name"] == doc_type}.first
        return spec_for_type["source_fields"]
    end

end
