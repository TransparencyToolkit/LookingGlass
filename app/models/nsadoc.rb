class Nsadoc
  include Elasticsearch::Persistence::Model

  settings = JSON.parse(File.read("app/dataspec/importer.json")).first
  fieldList = JSON.parse(File.read(settings["Data Template"]))
  index_name settings["Index Name"]
  
  fieldhash = Hash.new
  fieldList.each do |f|
    # Set mapping
    map = Hash.new
    if f["Mapping"] == "not_analyzed"
      map[:index] = f["Mapping"]
    elsif f["Mapping"] == "english"
      map[:analyzer] == "english"
    end
    
    # If facet, make separate analyzed version. 
    if f["Facet?"] == "Yes"
      attribute (f["Field Name"]+"_analyzed").to_sym, f["Type"], mapping: map
      attribute f["Field Name"].to_sym, f["Type"], mapping: {index: "not_analyzed"}
    else # For non-facets                    
      attribute f["Field Name"].to_sym, f["Type"], mapping: map
    end
  end
end
