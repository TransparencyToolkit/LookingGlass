module IndexMethods
  attr_accessor :settings, :mappings
  # Load all dataspec info
  def loadDataspec
    getFieldInfo
    getDisplayPrefs
    getDatasetDetails
  end

  # Gets the details for each field                                                                     
  def getFieldInfo
    @importer = JSON.parse(File.read("app/dataspec/importer.json")).first
    @config_dir = @importer["Dataset Config"]
    @field_info = JSON.parse(File.read(@config_dir+"field_details.json"))
    @field_info_sorted = @field_info.sort_by{|field| field["Location"].to_i}
  end

  # Get where each field should show up                                                                       
  def getDisplayPrefs
    display_prefs = JSON.parse(File.read(@config_dir+"display_prefs.json"))
    @facet_fields = display_prefs["Facet"]
    @searchable_fields = display_prefs["Searchable"]
    @fields_in_results = display_prefs["In Search Results"]
    @default_fields_in_results = display_prefs["In Search Results by Default"]
    @doc_page_fields = display_prefs["On Doc Page"]
    @item_fields = display_prefs["Item Field"]
    @truncated_fields = display_prefs["Truncate Text"]
  end

  # Gets where the dataset is and how it is structured                                                             
  def getDatasetDetails
    dataset_details = JSON.parse(File.read(@config_dir+"dataset_details.json"))
    @index_name = dataset_details["Index Name"]
    @data_path_type = dataset_details["Path Type"]
    @data_path = dataset_details["Path"]
    @ignore_ext = dataset_details["Ignore Dir Import Ext"]
  end
end
