source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.1.3'
gem 'builder', '~> 3.0'   
gem 'i18n' # Need this explicitly, otherwise can't deploy

gem 'mysql2', '~> 0.3.8'  
gem 'pg'
#tmp# gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

#tmp# dependency for linecache
gem 'require_relative'

gem 'json', '~> 1.6'
gem 'haml', '~> 3.1'
gem 'sass', '~> 3.1'
gem 'coffee-script', '~> 2.2'
gem 'jquery-rails', '= 1.0.16' # NOTE .live will be deprecated in the future && upgrade jquery.inview plugin before upgrade to '~> 1.0'
gem 'rails_autolink', '~> 1.0'
gem 'jquery-tmpl-rails'
gem 'haml_assets'

# Gems used only for assets and not required in production environments by default.
group :assets do
  gem 'sass-rails', '~> 3.1'
  gem 'coffee-rails', '~> 3.1'
  gem 'uglifier', '~> 1.1'
end

gem 'cancan', '~> 1.6'

gem 'will_paginate', '~> 3.0' 

gem 'zip', '~> 2.0.2' # alternatives: 'rubyzip', 'zipruby', 'zippy'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'

gem 'nested_set', '~> 1.6.8'
gem 'acts-as-dag', '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

gem 'net-ldap', :require => 'net/ldap'

gem 'zencoder', '~> 2.3.1'
gem 'uuidtools', '~> 2.1.2'
gem 'mini_exiftool', '~> 1.3.1'
# gem 'mini_magick', '~> 3.3'
# gem 'streamio-ffmpeg'

gem 'irwi', :git => 'git://github.com/alno/irwi.git', :ref => 'b78694'
gem 'RedCloth'

group :test, :development do
  gem 'autotest'
  gem 'database_cleaner'
  gem 'factory_girl', "~> 2.1.0"
  gem 'factory_girl_rails', "~> 1.2"
  gem 'faker'
  gem 'pry'
  gem 'rspec-rails'
  gem 'statsample'
  gem 'watchr'
  gem 'wirble'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  #tmp# gem 'peterhoeg-railroad'
  #tmp# gem 'newrelic_rpm', '~> 3.1'
end

group :test do
  gem 'cover_me'
  gem 'capybara', '~> 1.1'
  gem 'cucumber'#, '~> 1.0.3'
  gem 'cucumber-rails'#, '~> 1.0.2'
  gem 'launchy'  
  gem 'rspec-rails'
  gem 'selenium-webdriver', '~> 2.12'
  gem 'simplecov' # for Ruby 1.8.x:  gem 'rcov'
  gem 'spork'
end
