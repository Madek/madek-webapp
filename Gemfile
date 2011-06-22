source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.1.0.rc4'  
gem 'builder', '~> 3.0'   
gem 'i18n' # Need this explicitly, otherwise can't deploy

gem 'mysql2', '~> 0.3.6'  
gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

#tmp# dependency for linecache
gem 'require_relative'

gem 'haml', '~> 3.1.2'
gem 'sass', '~> 3.1.3' # Haml will no longer automatically load Sass in Haml 3.2.0. # Please add gem 'sass' to your Gemfile.
gem 'coffee-script'
gem 'uglifier'
gem 'sprockets', '2.0.0.beta.10' #tmp# 2.0.0.beta.11 doesn't work

gem 'jquery-rails', '~> 1.0'
gem 'rails_autolink', '~> 1.0.2'

#gem 'will_paginate', '~> 3.0.pre2' 
gem 'will_paginate', :git => 'git://github.com/JackDanger/will_paginate.git' # fix for CollectionAssociation

gem 'thinking-sphinx', '~> 2.0.5', :require => 'thinking_sphinx'
#temp#sphinx# gem 'ts-delayed-delta', '1.1.0', :require => 'thinking_sphinx/deltas/delayed_delta'

gem 'zip', '~> 2.0.2'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'

gem 'nested_set', '~> 1.6.7'
gem 'acts-as-dag', '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

# gem 'rmagick', '2.13.1', :require => 'RMagick2'
gem 'json', '~> 1.5.3'

gem 'ruby-net-ldap', '~> 0.0.4', :require => 'net/ldap'

gem 'zencoder'
gem 'uuidtools'
gem 'mini_exiftool'

# wiki:
# unfortunately upstream irwi is broken. Until it is fixed we
# install it as a plugin from our own branch on github:
# git@github.com:tpo/irwi.git
gem 'irwi', :git => 'git://github.com/tpo/irwi.git'
gem 'RedCloth'

group :test, :development do
  gem 'ruby-debug'
  #gem 'ruby-debug19', :require => 'ruby-debug' # for Ruby 1.9.x
  gem 'ruby-debug-completion'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  #tmp# gem 'peterhoeg-railroad'
end

group :test do
  gem 'cucumber', '~> 0.10.6'
  gem 'cucumber-rails', '~> 0.5.2'
  gem 'capybara', '~> 1.0.0'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'spork'
  gem 'launchy'  
  gem 'rcov'
end
