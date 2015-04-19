class Nsadoc
  extend IndexMethods
  include Elasticsearch::Persistence::Model
  include ENAnalyzer

  # List of fields from other file (and question index methods and synonyms)
  # Split out mapping setting into own method
 
  config = JSON.parse(File.read("app/dataspec/importer.json")).first
  fieldList = JSON.parse(File.read(config["Data Template"]))
  index_name config["Index Name"]
  
  self.settings = ENAnalyzer::analyzerSettings
 

  def self.genMapping(settings, fieldList)
    fieldhash = Hash.new
    fieldList.each do |f|
      # Set mapping
      map = Hash.new
      if f["Mapping"] == "not_analyzed"
        map[:index] = f["Mapping"]
      elsif f["Mapping"] == "english"
        map[:analyzer] = "custom_en_analyzer"
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

  genMapping(settings, fieldList)
end
