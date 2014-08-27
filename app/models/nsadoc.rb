class Nsadoc
  include Elasticsearch::Persistence::Model

  # Fields to have raw copies: released_by, type, legal_authority, records_collected, sigads, codewords, programs, countries
  # Make sure dates index okay and can be queried (release_date and creation_date)
  # Do nothing: article_url and doc_path

  attribute :release_date, Date, mapping: {index: 'not_analyzed'}
  attribute :released_by, String, mapping: {index: 'not_analyzed'}
  attribute :article_url, String, mapping: {index: 'not_analyzed'}
  attribute :title, String, mapping: {analyzer: 'snowball'}
  attribute :doc_path, String, mapping: {index: 'not_analyzed'}
  attribute :type, String, mapping: {index: 'not_analyzed'}
  attribute :legal_authority, String, mapping: {index: 'not_analyzed'}
  attribute :records_collected, String, mapping: {index: 'not_analyzed'}
  attribute :creation_date, Date, mapping: {index: 'not_analyzed'}
  attribute :doc_text, String, mapping: {analyzer: 'snowball'}
  attribute :aclu_desc, String, mapping: {analyzer: 'snowball'}
  attribute :sigads, String, mapping: {index: 'not_analyzed'}
  attribute :codewords, String, mapping: {index: 'not_analyzed'}
  attribute :codewords_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :programs, String, mapping: {index: 'not_analyzed'}
  attribute :programs_analyzed, String, mapping: {analyzer: 'snowball'}
  attribute :countries, String, mapping: {index: 'not_analyzed'}
end
