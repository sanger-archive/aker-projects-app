# frozen_string_literal: true

source 'https://rubygems.org'

# Force git gems to use secure HTTPS
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 3.2'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'uuid', '~> 2.3'
gem 'active_model_serializers', '~> 0.10'
gem 'bunny', '= 0.9.0.pre10'

gem 'aker_credentials_gem', github: 'sanger/aker-credentials'
gem 'aker_permission_gem', github: 'sanger/aker-permission'
gem 'aker-billing-facade-client', github: 'sanger/aker-billing-facade-client'
gem 'aker_shared_navbar', github: 'sanger/aker-shared-navbar'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'bootstrap_form'
gem 'zipkin-tracer'
gem 'loading_mask'
gem 'js-routes'

gem 'json_api_client', github: 'sanger/json_api_client'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'bootstrap-sass', '~> 3.3.6'
gem 'font-awesome-sass'
gem 'rubocop', '~> 0.52', require: false
gem 'pg', '~> 0.18' # pg version 1.0.0 is not compatible with Rails 5.1.4
gem 'jsonapi-resources', '~> 0.8'
gem 'therubyracer'

group :development, :test do
  gem 'rspec-rails', '~> 3.4'
  gem 'launchy'
  gem 'capybara'
  gem 'poltergeist'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'json-schema'
  gem 'brakeman', require: false
  gem 'timecop'
end

gem 'simplecov', :require => false, :group => :test
gem 'simplecov-rcov', :group => :test
gem 'rubycritic', :group => :test
