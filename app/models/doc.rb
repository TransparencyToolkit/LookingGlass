class Doc
  extend IndexMethods
  include Elasticsearch::Persistence::Model
  include ENAnalyzer
 
  # Load dataspec, analyzer settings and set index name
  loadDataspec
  index_name @importer["Index Name"]
  self.settings = ENAnalyzer::analyzerSettings
 

  def self.genMapping(settings)
    fieldhash = Hash.new
    @field_info.each do |f|
      # Set mapping
      map = Hash.new
      if f["Mapping"] == "not_analyzed"
        map[:index] = f["Mapping"]
      elsif f["Mapping"] == "english"
        map[:analyzer] = "custom_en_analyzer"
      end
    
      # If facet, make separate analyzed version. 
      if @facet_fields.include?(f["Field Name"])
        attribute (f["Field Name"]+"_analyzed").to_sym, f["Type"], mapping: map
        attribute f["Field Name"].to_sym, f["Type"], mapping: {index: "not_analyzed", fielddata: {format: "doc_values"}}
      else # For non-facets                    
        attribute f["Field Name"].to_sym, f["Type"], mapping: map
      end
    end
  end

  genMapping(settings)
end
