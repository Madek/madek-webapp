
# Otherwise Passenger/Rack throws a hissy fit
# http://stackoverflow.com/questions/8252160/invalid-byte-sequence-error-in-normalize-yaml-input-being-thrown
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'
source 'http://gems.github.com'

# RAILS
gem 'rails', '3.2.11'

# DATABASE
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
gem 'composite_primary_keys', '~> 5.0.10'
gem 'foreigner'
gem 'jdbc-postgres', platform: :jruby
gem 'memcache-client' 
gem 'pg', platform: :mri_19

# THE REST
gem 'RedCloth'
gem 'activeadmin', '~> 0.5.0'
gem 'coffee-filter', "~> 0.1.1"
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
gem 'nokogiri'
gem 'quiet_assets', group: :development
gem 'rails_autolink', '~> 1.0'
gem 'require_relative'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'
gem 'sass', '~> 3.2'
gem 'uuidtools', '~> 2.1.3'
gem 'kaminari', '~> 0.14' 
gem 'zencoder', '~> 2.4'
gem 'zip', '~> 2.0.2' # alternatives: 'rubyzip', 'zipruby', 'zippy'

group :assets do
  gem 'coffee-rails', '~> 3.2'
  gem 'execjs'
  gem 'haml_coffee_assets'
  gem 'sass-rails', '~> 3.2'
  gem 'compass-rails'
  gem 'uglifier', '~> 1.2'
end

group :production do
  gem 'newrelic_rpm', '~> 3.4'
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
  gem 'guard-rspec', '~> 2.1'
  gem 'guard-spork', '~> 1.1', platform: :mri_19
  gem 'poltergeist'
  gem 'pry'
  gem 'rb-fsevent', '~> 0.9'
  gem 'rest-client'
  gem 'rspec-rails'
  gem 'ruby_gntp', '~> 0.3.4'
  gem 'spork-rails'
end

group :development, :production do
  # we could use yard with an other mkd provider https://github.com/lsegal/yard/issues/488
  platform :mri_19 do
    gem "yard", "~> 0.8.3"
    gem "yard-rest", "~> 1.1.4"
    gem 'redcarpet' # yard-rest dependency
  end
end

group :development do
  # CSS styleguides
  gem 'nkss-rails', :git => 'git://github.com/interactivethings/nkss-rails.git'
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'capybara-screenshot'
  gem 'cucumber', '~> 1.2'
  gem 'cucumber-rails', '~> 1.3', :require => false
  gem 'launchy'  
  gem 'selenium-webdriver', '~> 2.25'
  gem 'simplecov', '~> 0.6'
  gem 'therubyracer', :platform => :mri_19
  gem 'therubyrhino', :platform => :jruby
end
