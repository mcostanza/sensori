source 'https://rubygems.org'

gem 'rails', '3.2.12'

gem 'mysql2'

gem 'less-rails'
gem 'less-rails-bootstrap', "~> 2.3"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  
  # Required for less
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :test, :development do
  gem 'rspec-rails', '~> 2.0'
  gem 'factory_girl_rails'

  # Javascript unit tests
  gem 'jasmine'
  # Javascript mocking library
  gem "sinon-rails"
end

group :test do
  # For testing Sidekiq jobs
  gem 'test_after_commit'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
gem 'debugger'

# Cannot run `rails console` from AWS elastic beanstalk without this, probably a rails bug: https://github.com/rails/rails/issues/9256
gem 'minitest', "~> 4.7.5"

# AWS Email
gem "aws-ses"

gem 'rake'

gem "soundcloud"

# Add foreign key support for migrations
gem "foreigner"

# pagination
gem "kaminari"

# FriendlyId for slug lookups
gem "friendly_id", "~> 4.0.9"

# AutoHTML plugin for html formatting discussions, responses, etc
gem "auto_html"

# File uploads (including s3)
gem "carrierwave"

# Image processing
gem "rmagick"

# S3 file uploads
gem "fog"

# Background jobs
gem "sidekiq"

# JQuery File Upload
gem "jquery-fileupload-rails"

# Editor for tutorials, etc
# Forked version using wysihtml5 version 0.4.0pre
gem "bootstrap-wysihtml5-rails", :git => "https://sensoricollective@bitbucket.org/sensoricollective/bootstrap-wysihtml5-rails.git"

# Backbone JS library
gem "rails-backbone", '>= 0.9.10'
