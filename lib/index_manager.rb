require 'open-uri'
require 'pry'
require 'datapackage.rb'
load 'generate_id.rb'
load 'index_methods.rb'
load 'date_funcs.rb'
load 'misc_process.rb'
load 'deduplicate_data.rb'
load 'process_data.rb'
load 'import_support.rb'

class IndexManager
  extend IndexMethods
  include ENAnalyzer
  extend GenerateId
  extend DateFuncs
  extend MiscProcess
  extend DeduplicateData
  extend ProcessData
  extend ImportSupport
  
  # Index creation
  def self.create_index(options={})
    # Make client, get settings, set name
    client = Doc.gateway.client
    
    loadDataspec
    Doc.index_name = @index_name
    
    # Delete index if it already exists
    client.indices.delete index: @index_name rescue nil if options[:force]
    
    settings = ENAnalyzer.analyzerSettings
    mappings = Doc.mappings.to_hash
    
    # Create index with appropriate settings and mappings
    client.indices.create index: @index_name,
    body: {
      settings: settings.to_hash,
      mappings: mappings.to_hash }
  end

  # Import data from different formats
  def self.import_data(options={})
    create_index force: true if options[:force]
    
    # Import from file, link, or dir
    case @data_path_type
    when "File"
      importFromFile
    when "url"
      importFromURL
    when "Directory"
      Dir.glob(@data_path+"/**/*.json") do |file|
        if !file.include? @ignore_ext
          begin
            importFileInDir(file)
          rescue
            binding.pry
          end
        end
      end
    end
  end
end

