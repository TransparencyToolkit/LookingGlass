class Nsadoc
  include Elasticsearch::Persistence::Model

  attribute :release_date, Date, mapping: {index: 'not_analyzed'}
  attribute :released_by, String, mapping: {index: 'not_analyzed'}
  attribute :released_by_analyzed, String, mapping: {analyzer: 'english'}
  attribute :article_url, String, mapping: {index: 'not_analyzed'}
  attribute :title, String, mapping: {analyzer: 'english'}
  attribute :doc_path, String, mapping: {index: 'not_analyzed'}
  attribute :type, String, mapping: {index: 'not_analyzed'}
  attribute :type_analyzed, String, mapping: {analyzer: 'english'}
  attribute :legal_authority, String, mapping: {index: 'not_analyzed'}
  attribute :legal_authority_analyzed, String, mapping: {analyzer: 'english'}
  attribute :records_collected, String, mapping: {index: 'not_analyzed'}
  attribute :records_collected_analyzed, String, mapping: {analyzer: 'english'}
  attribute :creation_date, Date, mapping: {index: 'not_analyzed'}
  attribute :doc_text, String, mapping: {analyzer: 'english'}
  attribute :aclu_desc, String, mapping: {analyzer: 'english'}
  attribute :sigads, String, mapping: {index: 'not_analyzed'}
  attribute :sigads_analyzed, String, mapping: {analyzer: 'english'}
  attribute :codewords, String, mapping: {index: 'not_analyzed'}
  attribute :codewords_analyzed, String, mapping: {analyzer: 'english'}
  attribute :programs, String, mapping: {index: 'not_analyzed'}
  attribute :programs_analyzed, String, mapping: {analyzer: 'english'}
  attribute :countries, String, mapping: {index: 'not_analyzed'}
  attribute :countries_analyzed, String, mapping: {analyzer: 'english'}
end
