source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.1'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3'

gem 'mysql2'
gem 'yaml_db', github: 'jetthoughts/yaml_db', ref: 'fb4b6bd7e12de3cffa93e0a298a1e5253d7e92ba'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'typhoeus'
gem 'nokogiri'
gem 'tesseract-ocr'
gem "mini_magick"
# gem  "execjs"
ENV['CFLAGS'] = '-I/usr/local/Cellar/tesseract/3.02.02/include -I/usr/local/Cellar/leptonica/1.69/include' 
ENV['LDFLAGS'] = '-L/usr/local/Cellar/tesseract/3.02.02/lib -L/usr/local/Cellar/leptonica/1.69/lib'

gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'

#分頁
gem 'will_paginate'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development
gem 'capistrano', '~> 2.15'
gem 'capistrano-ext'

gem 'net-ssh', '~> 2.8.1', :git => "https://github.com/net-ssh/net-ssh"

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'rspec-rails'
gem 'capybara'
gem 'selenium-webdriver'
