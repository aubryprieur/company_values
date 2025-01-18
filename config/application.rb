require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module CompagnyValues
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.assets.css_compressor = nil
    config.time_zone = 'Paris'
    config.i18n.available_locales = [:fr]
    config.i18n.default_locale = :fr
  end
end
