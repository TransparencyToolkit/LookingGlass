module IndexMethods
  attr_accessor :settings, :mappings
  # Load all dataspec info
  def loadDataspec
    getFieldInfo
    getDisplayPrefs
    getDatasetDetails
    getImportConfig
    getAttachConfig
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

  # Get import config details
  def getImportConfig
    dataset_details = JSON.parse(File.read(@config_dir+"import_config.json"))
    @id_field = dataset_details["ID Field"]
    @id_secondary = dataset_details["Secondary ID"]
    @get_after = dataset_details["Get ID After"]
    @synonym_list = dataset_details["Synonym List"]
    @ignore_list = dataset_details["Ignore List"]
    @dedup_ignore = dataset_details["Deduplicate Ignore"]
    @dedup_prioritize = dataset_details["Deduplicate Prioritize"]
  end

  # Get config settings for attachments (pdfs and images)
  def getAttachConfig
    attach_config = JSON.parse(File.read(@config_dir+"attach_config.json"))
    @pdf_tab = attach_config["Show PDF?"]
    @attach_prefix = attach_config["File Path Prefix"]
    @attach_attr = attach_config["File Path Attr"]
  end
end
