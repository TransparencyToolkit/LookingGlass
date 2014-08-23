class Nsadoc
  include Elasticsearch::Persistence::Model

  attribute :release_date, Date, mapping: {index: 'not_analyzed'}
  attribute :released_by, String, mapping: {index: 'not_analyzed'}
  attribute :article_url, String, mapping: {index: 'not_analyzed'}
  attribute :title, String
  attribute :doc_path, String, mapping: {index: 'not_analyzed'}
  attribute :type, String, mapping: {index: 'not_analyzed'}
  attribute :legal_authority, String, mapping: {index: 'not_analyzed'}
  attribute :records_collected, String, mapping: {index: 'not_analyzed'}
  attribute :creation_date, Date, mapping: {index: 'not_analyzed'}
  attribute :doc_text, String
  attribute :aclu_desc, String, mapping: {index: 'not_analyzed'}
  attribute :sigads, String, mapping: {index: 'not_analyzed'}
  attribute :codewords, String, mapping: {index: 'not_analyzed'}
  attribute :programs, String, mapping: {index: 'not_analyzed'}
  attribute :countries, String, mapping: {index: 'not_analyzed'}
end
