source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.1.3'
gem 'builder', '~> 3.0'   
gem 'rabl'
gem 'i18n' # Need this explicitly, otherwise can't deploy

gem 'mysql2', '~> 0.3.8'  
gem 'pg'
#tmp# gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

#tmp# dependency for linecache
gem 'require_relative'

gem 'json', '~> 1.6'
gem 'rjson'
gem 'haml', '~> 3.1'
gem 'formtastic'
gem 'sass', '~> 3.1'
gem 'coffee-script', '~> 2.2'
gem "coffee-filter", "~> 0.1.1"

#                          _             
#                         (_)            
#__      ____ _ _ __ _ __  _ _ __   __ _ 
#\ \ /\ / / _` | '__| '_ \| | '_ \ / _` |
# \ V  V / (_| | |  | | | | | | | | (_| |
#  \_/\_/ \__,_|_|  |_| |_|_|_| |_|\__, |
#                                   __/ |
#                                  |___/ 
# NOTE WARNING DO NOT CHANGE THIS LINE
gem 'jquery-rails', '= 1.0.16'
# DO NOT CHANGE, OTHERWISE ENDLESS SCROLLING STOPS WORKING (BECAUSE OF OUR INVIEW PLUGIN),
# OTHER THINGS STOP WORKING ALSO
#
gem 'rails_autolink', '~> 1.0'
gem 'jquery-tmpl-rails'
gem 'haml_assets'
gem "plupload-rails", "~> 1.0.6"

# Gems used only for assets and not required in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.1'
  gem 'coffee-rails', '~> 3.1'
  gem 'uglifier', '~> 1.1'
end

#tmp# gem 'cancan', '~> 1.6'

gem 'ledermann-rails-settings', :require => 'rails-settings' # alternatives: 'settingslogic', 'settler', 'rails_config', 'settings', 'simpleconfig' 

gem 'will_paginate', '~> 3.0' 

gem 'zip', '~> 2.0.2' # alternatives: 'rubyzip', 'zipruby', 'zippy'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'

gem 'nested_set', '~> 1.6.8'
gem 'acts-as-dag', '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

gem 'net-ldap', :require => 'net/ldap'

gem 'zencoder', '2.4.0'
gem 'uuidtools', '~> 2.1.2'
#not used anymore# gem 'mini_exiftool', '~> 1.3.1'
# gem 'mini_magick', '~> 3.3'
# gem 'streamio-ffmpeg'

gem 'irwi', :git => 'git://github.com/alno/irwi.git', :ref => 'b78694'
gem 'RedCloth'

gem 'newrelic_rpm', '~> 3.3'

gem 'nokogiri'

group :test, :development do
  gem "guard", "~> 0.10.0"
  gem "guard-cucumber", "~> 0.7.4"
  gem "guard-rspec", "~> 0.6.0"
  gem "guard-spork", "~> 0.5.1"
  gem "guard-jasmine-headless-webkit", "~> 0.3.2"
  gem "jasmine-headless-webkit", "~> 0.8.4" # needed for "headless" running of jasmine tests (needed for CI)
  gem "jasmine-rails", "~> 0.0.2" # javascript test environment
  gem "jasminerice", "~> 0.0.8" # needed for implement coffeescript, fixtures and asset pipeline serverd css into jasmine
  gem "rb-fsevent", "~> 0.4.3.1"
  gem "ruby_gntp", "~> 0.3.4"
  gem 'autotest'
  gem 'database_cleaner'
  gem 'factory_girl', "~> 2.1.0"
  gem 'factory_girl_rails', "~> 1.2"
  gem 'faker'
  gem 'pry'
  gem 'railroady'
  gem 'statsample'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
end

group :development, :production do
  gem "yard", "~> 0.7.4"
  gem "yard-rest", :git => "git://github.com/spape/yard-rest-plugin.git"
  gem 'redcarpet' # yard-rest dependency
end

group :test do
  # gem 'cover_me' # CAUSING ERRORS FIXME
  gem 'simplecov' 
  gem 'capybara', '~> 1.1'
  gem 'cucumber'#, '~> 1.0.3'
  gem 'cucumber-rails', '~> 1.3', :require => false
  gem 'launchy'  
  gem 'rspec-rails'
  gem 'selenium-webdriver', '~> 2.12'
  gem 'simplecov' # for Ruby 1.8.x:  gem 'rcov'
  gem 'spork'
end
