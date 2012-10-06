source 'http://rubygems.org'
source 'http://gems.github.com'

# RAILS
gem 'rails', '3.2.8'

# DATABASE
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
gem 'foreigner'
gem 'jdbc-postgres', platform: :jruby
gem 'memcache-client' 
gem 'mysql2', '~> 0.3.11', platform: :mri_19
gem 'pg', platform: :mri_19

# THE REST
gem "coffee-filter", "~> 0.1.1"
gem "d3_rails", "~> 2.10"
gem 'RedCloth'
gem 'coffee-script', '~> 2.2'
gem 'haml', '~> 3.1'
gem 'haml_assets'
gem 'irwi', :git => 'git://github.com/alno/irwi.git', :ref => 'b78694'
gem 'jquery-rails', '= 1.0.16' # NOTE WARNING DO NOT CHANGE THIS LINE
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'jruby-openssl', platform: :jruby
gem 'json', '~> 1.7'
gem 'ledermann-rails-settings', :require => 'rails-settings' # alternatives: 'settingslogic', 'settler', 'rails_config', 'settings', 'simpleconfig' 
gem 'nested_set', '~> 1.7'
gem 'net-ldap', :require => 'net/ldap', :git => 'git://github.com/justcfx2u/ruby-net-ldap.git'
gem 'newrelic_rpm', '~> 3.4'
gem 'nokogiri'
gem 'rails_autolink', '~> 1.0'
gem 'require_relative'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'
gem 'sass', '~> 3.2'
gem 'uuidtools', '~> 2.1.3'
gem 'will_paginate', '~> 3.0' 
gem 'zencoder', '~> 2.4'
gem 'zip', '~> 2.0.2' # alternatives: 'rubyzip', 'zipruby', 'zippy'

group :assets do
  gem 'coffee-rails', '~> 3.2'
  gem 'sass-rails', '~> 3.2'
  gem 'uglifier', '~> 1.2'
end

group :development, :personas do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'railroady'
  gem 'rvm-capistrano'
  gem 'statsample'
  gem 'thin', platform: :mri_19 # web server (Webrick do not support keep-alive connections)
end

group :test, :development, :personas do
  gem 'autotest'
  gem 'database_cleaner'
  gem 'factory_girl', '~> 4.0'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'faraday'
  gem 'guard', '~> 1.3'
  gem 'guard-cucumber', '~> 1.2'
  gem 'guard-rspec', '~> 1.2'
  gem 'guard-spork', '~> 1.1', platform: :mri_19
  gem 'spork-rails'
  gem 'pry'
  gem 'rb-fsevent', '~> 0.9'
  gem 'rest-client'
  gem 'rspec-rails'
  gem 'ruby_gntp', '~> 0.3.4'
end

group :development, :production do
  # we could use yard with an other mkd provider https://github.com/lsegal/yard/issues/488
  platform :mri_19 do
    gem "yard", "~> 0.8.2.1"
    gem "yard-rest", "~> 1.1.4"
    gem 'redcarpet' # yard-rest dependency
  end
end

group :test do
  gem 'capybara', '~> 1.1'
  gem 'capybara-screenshot'
  gem 'cucumber', '~> 1.2'
  gem 'cucumber-rails', '~> 1.3', :require => false
  gem 'launchy'  
  gem 'selenium-webdriver', '~> 2.25'
  gem 'simplecov', '~> 0.6'
  gem 'therubyracer', :platform => :mri_19
  gem 'therubyrhino', :platform => :jruby
end
