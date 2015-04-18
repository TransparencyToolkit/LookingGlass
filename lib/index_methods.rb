module IndexMethods
  attr_accessor :settings, :mappings, :index_name, :importPath

  # Set index name and other attributes
  def getSettings
    @index_settings = JSON.parse(File.read("app/dataspec/importer.json")).first
  end

  # Gets the import path settings
  def importPath
    return @index_settings["Path"]
  end
end
