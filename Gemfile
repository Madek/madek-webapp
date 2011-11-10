source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.1.1'
gem 'builder', '~> 3.0'   
gem 'i18n' # Need this explicitly, otherwise can't deploy

gem 'mysql2', '~> 0.3.7'  
#tmp# gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

#tmp# dependency for linecache
gem 'require_relative'

gem 'json', '~> 1.6'
gem 'haml', '~> 3.1'
gem 'sass', '~> 3.1'
gem 'coffee-script', '~> 2.2'
gem 'uglifier', '~> 1.0'

gem 'jquery-rails', '~> 1.0'
gem 'rails_autolink', '~> 1.0'

gem 'will_paginate', '~> 3.0' 

gem 'thinking-sphinx', '~> 2.0.10', :require => 'thinking_sphinx'
#temp#sphinx# gem 'ts-delayed-delta', '1.1.0', :require => 'thinking_sphinx/deltas/delayed_delta'

gem 'zip', '~> 2.0.2'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'

gem 'nested_set', '~> 1.6.8'
gem 'acts-as-dag', '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

gem 'net-ldap', :require => 'net/ldap'

gem 'zencoder'
gem 'uuidtools'
gem 'mini_exiftool'

gem 'irwi', :git => 'git://github.com/alno/irwi.git', :ref => 'b78694'
gem 'RedCloth'

group :test, :development do
  gem 'ruby-debug19', :require => 'ruby-debug' # for Ruby 1.8.x: gem 'ruby-debug'
  gem 'ruby-debug-completion'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  #tmp# gem 'peterhoeg-railroad'
  #tmp# gem 'newrelic_rpm', '~> 3.1'
end

group :test do
  gem 'cucumber'#, '~> 1.0.3'
  gem 'cucumber-rails'#, '~> 1.0.2'
  gem 'capybara', '~> 1.1.1'
  gem 'selenium-webdriver', '~> 2.6' 
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'spork'
  gem 'launchy'  
  gem 'simplecov' # for Ruby 1.8.x:  gem 'rcov'
end
