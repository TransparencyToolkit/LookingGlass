class DataspecContent
  # field_details.json
  attr_reader :config_dir, :field_info, :field_info_sorted

  # display_prefs.json
  attr_reader :facet_fields, :searchable_fields, :fields_in_results, :default_fields_in_results,
              :doc_page_fields, :item_fields, :truncated_fields

  # dataset_details.json
  attr_reader :index_name, :dataset_name, :data_path_type, :data_path, :ignore_ext, :sort_field, :show_sort_field

  # import_config.json
  attr_reader :id_field, :id_secondary, :get_after, :synonym_list, :ignore_list, :dedup_ignore,
              :dedup_prioritize

  # attach_config.json
  attr_reader :pdf_tab, :attach_prefix, :attach_attr, :web_tab, :web_url, :image_prefix

  # site_config.json
  attr_reader :site_config, :search_title
  
  def initialize(config_dir)
    @config_dir = config_dir
    loadDataspec
  end

  # Load all dataspec info
  def loadDataspec
    getFieldInfo
    getDisplayPrefs
    getDatasetDetails
    getImportConfig
    getAttachConfig
    getSiteConfig
  end

  # Gets the details for each field
  def getFieldInfo
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
    @dataset_name = dataset_details["Dataset Name"]
    @data_path_type = dataset_details["Path Type"]
    @data_path = dataset_details["Path"]
    @ignore_ext = dataset_details["Ignore Dir Import Ext"]
    @sort_field = dataset_details["Sort Field"]
    @show_sort_field = dataset_details["Show Sort Field"]
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
    @web_tab = attach_config["Show Webpage?"]
    @web_url = attach_config["Web URL"]
    @image_prefix = attach_config["Image Path Prefix"]
  end

  # Get site config (logo, name, info urls)
  def getSiteConfig
    @site_config = JSON.parse(File.read(@config_dir+"site_config.json"))
    @search_title = @site_config["Search Title"]
  end
end
