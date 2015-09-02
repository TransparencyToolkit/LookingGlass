module MultiDataset

  # Saves all dataspec values in @dataspecs
  def loadAllDatasets
    # Load dataspec paths
    dataspec_paths = JSON.parse(File.read("app/dataspec/importer.json"))[0]["Dataset Config"]
    @dataspecs = Array.new

    # Load all dataspecs into array
    dataspec_paths.each do |dataspec_dir|
      @dataspecs.push(DataspecContent.new(dataspec_dir))
    end
  end
end
