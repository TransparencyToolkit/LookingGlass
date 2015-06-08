module IndexMethods
  attr_accessor :settings, :mappings
  # Load all dataspec info
  def loadDataspec
    getFieldInfo
    getDisplayPrefs
  end

  # Gets the details for each field                                                                     
  def getFieldInfo
    @importer = JSON.parse(File.read("app/dataspec/importer.json")).first
    @field_info = JSON.parse(File.read(@importer["Data Template"]))
    @field_info_sorted = @field_info.sort_by{|field| field["Location"].to_i}
  end

  # Get where each field should show up                                                                       
  def getDisplayPrefs
    display_prefs = JSON.parse(File.read(@importer["Field Locations"]))
    @facet_fields = display_prefs["Facet"]
    @searchable_fields = display_prefs["Searchable"]
    @fields_in_results = display_prefs["In Search Results"]
    @default_fields_in_results = display_prefs["In Search Results by Default"]
    @doc_page_fields = display_prefs["On Doc Page"]
    @item_fields = display_prefs["Item Field"]
    @truncated_fields = display_prefs["Truncate Text"]
  end
end
