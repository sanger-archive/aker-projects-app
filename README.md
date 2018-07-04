# Aker - Projects app

[![Build Status](https://travis-ci.org/sanger/aker-projects-app.svg?branch=devel)](https://travis-ci.org/sanger/aker-projects-app)
[![Maintainability](https://api.codeclimate.com/v1/badges/3c7ab4a557c9f25d5362/maintainability)](https://codeclimate.com/github/sanger/aker-projects-app/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/3c7ab4a557c9f25d5362/test_coverage)](https://codeclimate.com/github/sanger/aker-projects-app/test_coverage)

# Installation
## Dev environment
1. Configure or update ports to services in `development.rb`.
2. Setup DB using `rails db:setup`. Alternatively, use:
  * `rails db:drop db:create db:migrate`
  * Seed DB with `rails db:seed` (first verify that your username has been added to the seed)

# Testing
## Requirements
* [PhantomJS](http://phantomjs.org/): `npm install phantomjs -g`

## Running tests
* Before running tests, make sure that the test database has been fully migrated: `bin/rails db:migrate RAILS_ENV=test`
To execute the current tests, run: `bundle exec rspec`

To run the Javascript tests, execute: `teaspoon`
