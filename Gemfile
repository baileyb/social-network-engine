source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.

group :assets do
  # gem 'sass-rails',   '~> 3.2.3'   # Disabling sass for now
  # gem 'coffee-rails', '~> 3.2.1'   # Disabling coffescript for now

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem "koala"

group :test, :development do
  gem "rspec-rails", "~> 2.0"
  gem "factory_girl_rails", "~> 4.0"
  gem "shoulda"
  gem 'vcr', '2.2.5'
end

group :test do
  gem 'webmock'
end

gem 'geocoder'

gem 'unicorn'

# Deploy with Capistrano
gem 'capistrano'

# Use thin instead of WEBrick
gem 'thin'

# For periodic tasks
gem 'whenever'