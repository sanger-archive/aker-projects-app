# frozen_string_literal: true

source 'https://rubygems.org'

# Force git gems to use secure HTTPS
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# All the gems not in a group will always be installed:
#   http://bundler.io/v1.6/groups.html#grouping-your-dependencies
gem 'active_model_serializers', '~> 0.10'
gem 'bootstrap-sass', '~> 3.3.6'
gem 'bootstrap_form'
gem 'bunny', '~> 2.9', '>= 2.9.2', require: false
gem 'coffee-rails', '~> 4.2' # Use CoffeeScript for .coffee assets and views
gem 'font-awesome-sass'
gem 'jbuilder', '~> 2.5' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'js-routes'
gem 'jsonapi-resources', '~> 0.8'
gem 'loading_mask'
gem 'pg', '~> 0.18' # pg version 1.0.0 is not compatible with Rails 5.1.4
gem 'puma', '~> 3.0' # Use Puma as the app server
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'therubyracer'
gem 'turbolinks', '~> 5' # Turbolinks makes navigating your web application faster.
gem 'uglifier', '~> 3.2' # Use Uglifier as compressor for JavaScript assets
gem 'uuid', '~> 2.3'
gem 'zipkin-tracer'

###
# Sanger gems
###
gem 'aker-billing-facade-client', github: 'sanger/aker-billing-facade-client'
gem 'aker_credentials_gem', github: 'sanger/aker-credentials'
gem 'aker_permission_gem', github: 'sanger/aker-permission'
gem 'aker_shared_navbar', github: 'sanger/aker-shared-navbar'
gem 'json_api_client', github: 'sanger/json_api_client'

###
# Groups
###
group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug', platform: :mri # Call 'byebug' anywhere in the code to get a debugger console
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'json-schema'
  gem 'launchy'
  gem 'phantomjs'
  gem 'poltergeist'
  gem 'rspec-rails', '~> 3.4'
  # Latest version of teaspoon (1.1.5) has a bug when executing teaspoon hooks that breaks the
  # tests by generating Http - 500 on hookup response from the server. This issue is solved only in
  # the master branch, so I'm selecting master until a new version of teaspoon is released.
  gem 'teaspoon', github: 'jejacks0n/teaspoon', branch: 'master'
  gem 'teaspoon-mocha'
  gem 'timecop'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'rubocop', '~> 0.52', require: false
  gem 'spring' # Spring speeds up development by keeping your application running in the background
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console' # Access an IRB console on exception pages or by using <%= console %>
end

group :test do
  gem 'database_cleaner'
  gem 'rubycritic'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
end
