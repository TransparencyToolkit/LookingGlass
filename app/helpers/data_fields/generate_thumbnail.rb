# Generates thumbnails for viewing images in the show view
module GenerateThumbnail
  # Generate thumbnail of the image
  def generate_thumbnail(doc, dataspec)
    image_path = get_text(doc, 'full_path', dataspec['source_fields']['full_path'])
    image_path = image_path.gsub("/attachments", "")
    curl_query_url = ENV['LOOKINGGLASS_URL']+thumbnail_path

    # Run the curl query
    http = Curl.get(curl_query_url, {file: image_path,
                                     size: '512x512'})
    return Base64.encode64(http.body_str)
  end
end
