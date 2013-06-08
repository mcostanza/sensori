source 'https://rubygems.org'

gem 'rails', '3.2.12'

gem 'mysql2'

gem 'less-rails'
gem 'less-rails-bootstrap'

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
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
gem 'debugger'

# Cannot run `rails console` from AWS elastic beanstalk without this, probably a rails bug: https://github.com/rails/rails/issues/9256
gem 'minitest'

# AWS Email
gem "aws-ses"

gem 'rake'

gem "soundcloud"