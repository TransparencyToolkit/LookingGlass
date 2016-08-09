module ESAnalyzer
  extend MultiDataset
  
  def self.analyzerSettings
    # Current LIMITATION: Takes synonym list from first dataspec- maybe pass in dataspec instead?
    
    # Load dataspecs but don't load all- that ends in an infinite loop
    @instance = InstanceSpec.new
    loadAllDatasets

    # Settings
    return {
      index: {
        analysis: {
          filter: {
            spanish_stop: {
              type: 'stop',
              stopwords: '_spanish_'
            },
            spanish_stemmer: {
              type: 'stemmer',
              language: 'light_spanish'
            },
            spanish_possessive_stemmer: {
              type: 'stemmer',
              language: 'possessive_spanish'
            },
            synonyms: {
              type: 'synonym',
              synonyms: File.read(@dataspecs[0].synonym_list).split("\n")
            }
          },       
          analyzer: {
            custom_es_analyzer: {
            type: 'custom',
            tokenizer: 'standard',
            filter: [
                     "spanish_possessive_stemmer",
                     "lowercase",
                     "synonyms",
                     "spanish_stop",
                     "spanish_stemmer",
                     "asciifolding"
                    ]
            },
          },
        },
      },
    }.freeze
  end
end
