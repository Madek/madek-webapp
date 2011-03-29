source 'http://rubygems.org'

gem 'rails', '3.0.5'
gem 'i18n' # Need this explicitly, otherwise can't deploy

gem 'mysql2', '0.2.6'
gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

gem 'themes_for_rails'
gem 'haml'
gem 'jquery-rails'

gem 'will_paginate', '3.0.pre2'
gem 'rgl', '0.4.0', :require => 'rgl/adjacency'
gem 'builder'

gem 'thinking-sphinx', '2.0.2', :require => 'thinking_sphinx'
#temp#sphinx# gem 'ts-delayed-delta', '1.1.0', :require => 'thinking_sphinx/deltas/delayed_delta'

gem 'zip', '2.0.2'

gem 'nested_set', '1.6.4'
gem 'acts-as-dag', '2.5.4' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

# gem 'rmagick', '2.13.1', :require => 'RMagick2'
gem 'json', '1.5.1'

gem "ruby-net-ldap", "0.0.4", :require => 'net/ldap'

gem "zencoder"
gem "uuidtools"

# wiki:
# unfortunately upstream irwi is broken. Until it is fixed we
# install it as a plugin from our own branch on github:
# git@github.com:tpo/irwi.git
#gem "irwi"
gem "RedCloth"

group :test, :development do
  gem 'ruby-debug' # TODO 'ruby-debug19' for Ruby 1.9.x
  gem 'ruby-debug-completion'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
end

group :test do
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'spork'
  gem 'steak'
  gem 'launchy'  
  gem 'rcov'
end
