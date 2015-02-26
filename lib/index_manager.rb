require 'open-uri'

class IndexManager
  def self.create_index(options={})
    client = Nsadoc.gateway.client
    index_name = Nsadoc.index_name

    client.indices.delete index: index_name rescue nil if options[:force]

    settings = Nsadoc.settings.to_hash
    mappings = Nsadoc.mappings.to_hash

    client.indices.create index: index_name,
    body: {
      settings: settings.to_hash,
      mappings: mappings.to_hash }
  end

  def self.import_from_json(options={})
    create_index force: true if options[:force]

    import_info = JSON.parse(File.read("app/dataspec/importer.json")).first

    # Import files, files from links, and directories of files
    if import_info["Path Type"] == "File"
      doc = JSON.parse(File.read(import_info["Path"]), symbolize_names: true)
    elsif import_info["Path Type"] == "url"
      doc = JSON.parse(URI.parse(import_info["Path"]).read, symbolize_names: true)
    end
    
    nsadocs = doc.map { |nsadoc_hash| process_nsadoc_info(nsadoc_hash, import_info)}
    inc = 1
    nsadocs.each do |d|
      Nsadoc.create d, id: inc
      inc += 1
    end
  end

  def self.process_nsadoc_info(nsadoc_hash, import_info)
    fieldList = JSON.parse(File.read(import_info["Data Template"]))
    fieldList.each do |f|

      # Handle unknown dates
      if f["Type"] == "Date"
        if nsadoc_hash[f["Field Name"].to_sym] == "Date unknown" || nsadoc_hash[f["Field Name"].to_sym] == "Unknown"
          nsadoc_hash[f["Field Name"].to_sym] = nil
        end
      end

      # Make analyzed version for facet fields (with same data as not_analyzed version)
      nsadoc_hash[(f["Field Name"]+"_analyzed").to_sym] = nsadoc_hash[f["Field Name"].to_sym] if f["Facet?"] == "Yes"
    end

    nsadoc_hash
  end
end
