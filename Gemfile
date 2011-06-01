source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'rails', '3.0.7' #Rails3.1# '3.1.0.rc1' 
gem 'builder', '~> 2.1.2' #Rails3.1# '~> 3.0'  
gem 'i18n' # Need this explicitly, otherwise can't deploy
gem 'rake', '~> 0.8.7' #'~> 0.9.1'

gem 'mysql2', '~> 0.2.7' #Rails3.1# '~> 0.3.2' 
gem 'memcache-client' #gem 'dalli' #gem 'redis-store'

gem 'haml', '~> 3.1.1'
gem 'sass', '~> 3.1.2' # Haml will no longer automatically load Sass in Haml 3.2.0. # Please add gem 'sass' to your Gemfile.
#gem 'coffee-script' #Rails3.1#
#gem 'uglifier' #Rails3.1#

gem 'jquery-rails', '~> 1.0'
#gem 'rails_autolink', '~> 1.0.1' #Rails3.1#

gem 'will_paginate', '~> 3.0.pre2' 
#gem 'will_paginate', :git => 'git://github.com/JackDanger/will_paginate.git' #Rails3.1# fix for CollectionAssociation

gem 'thinking-sphinx', '~> 2.0.5', :require => 'thinking_sphinx'
#gem 'thinking-sphinx', :git => 'git://github.com/sylogix/thinking-sphinx.git', :branch => "rails3", :require => 'thinking_sphinx' #Rails 3.1# fix for JoinDependency
#temp#sphinx# gem 'ts-delayed-delta', '1.1.0', :require => 'thinking_sphinx/deltas/delayed_delta'

gem 'zip', '~> 2.0.2'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'

gem 'nested_set', '~> 1.6.5'
gem 'acts-as-dag', '~> 2.5.5' # TOOD use instead ?? gem 'dagnabit', '2.2.6'

# gem 'rmagick', '2.13.1', :require => 'RMagick2'
gem 'json', '~> 1.5.1'

gem 'ruby-net-ldap', '~> 0.0.4', :require => 'net/ldap'

gem 'zencoder'
gem 'uuidtools'

# wiki:
# unfortunately upstream irwi is broken. Until it is fixed we
# install it as a plugin from our own branch on github:
# git@github.com:tpo/irwi.git
gem 'irwi', :git => 'git://github.com/tpo/irwi.git'
gem 'RedCloth'

group :test, :development do
  gem 'ruby-debug' # TODO 'ruby-debug19' for Ruby 1.9.x
  gem 'ruby-debug-completion'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  #tmp# gem 'peterhoeg-railroad'
end

group :test do
  gem 'cucumber'
  gem 'cucumber-rails', ">= 0.5.1"
  gem 'capybara'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'spork'
  gem 'launchy'  
  gem 'rcov'
end
