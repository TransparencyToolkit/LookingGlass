class Nsadoc
  include Elasticsearch::Persistence::Model

  attribute :release_date, Date, mapping: {index: 'not_analyzed'}
  attribute :released_by, String, mapping: {index: 'not_analyzed'}
  attribute :released_by_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :article_url, String, mapping: {index: 'not_analyzed'}
  attribute :title, String, mapping: {analyzer: 'snowball'}
  attribute :doc_path, String, mapping: {index: 'not_analyzed'}
  attribute :type, String, mapping: {index: 'not_analyzed'}
  attribute :type_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :legal_authority, String, mapping: {index: 'not_analyzed'}
  attribute :legal_authority_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :records_collected, String, mapping: {index: 'not_analyzed'}
  attribute :records_collected_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :creation_date, Date, mapping: {index: 'not_analyzed'}
  attribute :doc_text, String, mapping: {analyzer: 'snowball'}
  attribute :aclu_desc, String, mapping: {analyzer: 'snowball'}
  attribute :sigads, String, mapping: {index: 'not_analyzed'}
  attribute :sigads_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :codewords, String, mapping: {index: 'not_analyzed'}
  attribute :codewords_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :programs, String, mapping: {index: 'not_analyzed'}
  attribute :programs_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :countries, String, mapping: {index: 'not_analyzed'}
  attribute :countries_analyzed, String, mapping: {analyzer: 'snowball'}
end
