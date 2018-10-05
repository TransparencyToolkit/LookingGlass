module CatalystApi
  # Get full list of annotators
  def list_annotators
    http = Curl.get("#{ENV['CATALYST_URL']}/list_annotators")
    return JSON.parse(http.body_str)
  end
end
