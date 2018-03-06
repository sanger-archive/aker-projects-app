# Aker - Study management GUI

# Installation
## Dev environment
1. Configure or update ports to services in `development.rb`.
2. Setup DB using `rake db:setup`. Alternatively, use:
  * `rake db:drop db:create db:migrate`
  * Seed DB with `rake db:seed` (first verify that your username has been added to the seed)

# Testing
## Requirements
* [PhantomJS](http://phantomjs.org/): `npm install phantomjs -g`

## Running tests
* Before running tests, make sure that the test database has been fully migrated: `bin/rails db:migrate RAILS_ENV=test`
To execute the current tests, run: `bundle exec rspec`

To run the Javascript tests, execute: `teaspoon`
