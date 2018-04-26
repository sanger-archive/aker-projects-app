# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Projects
  class Application < Rails::Application

    config.middleware.insert_before Rack::Sendfile, ActionDispatch::DebugLocks

    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: true

      g.fixture_replacement :factory_girl, dir: 'spec/factories'

      g.assets false
    end

    config.ldap = config_for(:ldap)

    config.autoload_paths += %W["#{config.root}/app/forms"]

    # http://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html
    config.time_zone = 'London'

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
