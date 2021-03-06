require_relative 'boot'

#require 'rails/all'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LookingGlass
  class Application < Rails::Application
    config.relative_url_root=ENV['RAILS_RELATIVE_URL_ROOT']
    config.action_controller.permit_all_parameters = true
    config.autoload_paths += Dir[Rails.root.join('app', '{*/*}')]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
