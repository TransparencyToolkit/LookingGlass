class Nsadoc
  extend IndexMethods
  include Elasticsearch::Persistence::Model

  # Get working with stopwords, synonyms, asciifolding
  # Synonym lists in separate files (and import in spec)
  # Split out mapping setting
  # Change import from JSON/split out (and change index name setting)

  # Split out file/url/dir creation
  # Split out date parsing
  # Split out creation
  # Make sure each doc is only gone through once

  settings = JSON.parse(File.read("app/dataspec/importer.json")).first
  fieldList = JSON.parse(File.read(settings["Data Template"]))

  self.settings = {
    index: {
      analysis: {
        filter: {
          english_stop: {
            type: 'stop',
            stopwords: '_english_'
          },
          english_stemmer: {
            type: 'stemmer',
            language: 'english'
          },
          english_possessive_stemmer: {
            type: 'stemmer',
            language: 'possessive_english'
          },
          synonyms: {
            type: 'synonym',
            synonyms: [
                       "SIGINT,Signals Intelligence",
                       "xkeyscore,xks"
                      ]
          }
        },
        analyzer: { 
          custom_en_analyzer: {
            tokenizer: 'standard',
            filter: [
                     "english_possessive_stemmer",
                     "lowercase",
                     "synonym",
                     "english_stop",
                     "english_stemmer",
                     "asciifolding"
                    ] 
          },
        },
      },
    },
  }.freeze
  
  fieldhash = Hash.new
  fieldList.each do |f|
    # Set mapping
    map = Hash.new
    if f["Mapping"] == "not_analyzed"
      map[:index] = f["Mapping"]
    elsif f["Mapping"] == "english"
      map[:analyzer] == "custom_en_analyzer"
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
