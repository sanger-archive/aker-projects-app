Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.log_level = :debug

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.events = {
      enabled: false,
      broker_host: 'localhost',
      broker_port: '5672',
      broker_username: 'study_management',
      broker_password: 'password',
      vhost: 'aker',
      exchange: 'aker.events.tx'
  }

  config.fake_ldap = true

  config.jwt_secret_key = 'development'

  config.default_jwt_user = { email: ENV.fetch('USER', 'user') + '@sanger.ac.uk',
                              groups: ['world'] }

  config.login_url = 'http://localhost:9010/login'
  config.logout_url = 'http://localhost:9010/logout'
  config.auth_service_url = 'http://localhost:9010'

  config.urls = {
    reception: '',
    permissions: '',
    sets: '',
    projects: '',
    work: ''
  }

  config.billing_facade_url = 'http://localhost:3601'
  config.ubw_service_url = 'http://localhost:3602/'

  config.ubw = {
    enabled: false
  }
end
