json.array!(@nsadocs) do |nsadoc|
  json.extract! nsadoc, :id, :release_date, :released_by, :article_url, :title, :doc_path, :type, :legal_authority, :records_collected, :creation_date, :doc_text, :aclu_desc, :sigads, :codewords, :programs, :countries
  json.url nsadoc_url(nsadoc, format: :json)
end
