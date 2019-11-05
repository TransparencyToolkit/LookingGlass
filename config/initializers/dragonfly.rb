require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "effb3e4498f9acb8024eecfa5d9425d2338b058b1184877af0749d9f1ea287e6"

  url_format "/media/:job/:name"

  datastore :file,
    root_path: Rails.root.join('public/system/dragonfly', Rails.env),
    server_root: Rails.root.join('public')
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
ActiveSupport.on_load(:active_record) do
  extend Dragonfly::Model
  extend Dragonfly::Model::Validations
end
