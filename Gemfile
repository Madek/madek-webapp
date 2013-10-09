
# Otherwise Passenger/Rack throws a hissy fit
# http://stackoverflow.com/questions/8252160/invalid-byte-sequence-error-in-normalize-yaml-input-being-thrown
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'
source 'http://gems.github.com'

# RAILS
gem 'rails', '3.2.13'

# DATABASE
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
gem 'composite_primary_keys', '~> 5.0.10'
gem 'foreigner'
gem 'jdbc-postgres', platform: :jruby
gem 'memcache-client' 
gem 'pg', platform: :mri
gem 'postgres_ext'
gem 'textacular', git: 'https://github.com/DrTom/textacular.git'

# THE REST
gem 'activeadmin', :git => 'git://github.com/zhdk/active_admin.git' # '~> 0.5.0'
gem 'bcrypt-ruby', '~> 3.0.0' # TODO reevaluate with rails4; nasty stacktrace without version restriction; 
gem 'coffee-script'
gem 'compass-rails'
gem 'gettext_i18n_rails'
gem 'haml'
gem 'haml_assets'
gem 'jquery-rails', '= 1.0.16' # NOTE WARNING DO NOT CHANGE THIS LINE
gem 'jquery-tmpl-rails', '~> 1.1'
gem 'jruby-openssl', :platform => :jruby
gem 'json', '~> 1.7'
gem 'kaminari', '~> 0.14' 
gem 'nested_set', '~> 1.7'
gem 'net-ldap', :require => 'net/ldap', :git => 'git://github.com/justcfx2u/ruby-net-ldap.git'
gem 'nokogiri'
gem 'rails_autolink', '~> 1.0'
gem 'require_relative'
gem 'rgl', '~> 0.4.0', :require => 'rgl/adjacency'
gem 'sass', '~> 3.2.0'
gem 'uuidtools', '~> 2.1.3'
gem 'zencoder', '~> 2.4'
gem 'zip', '~> 2.0.2' # alternatives: 'rubyzip', 'zipruby', 'zippy'
gem 'animation'

group :assets do
  gem 'bootstrap-sass' 
  gem 'coffee-rails'
  gem 'execjs'
  gem 'font-awesomeplus-sass-rails', git: 'https://github.com/DrTom/font-awesome-plus-sass-rails.git'
  gem 'haml_coffee_assets'
  gem 'sass-rails'
  gem 'uglifier', '~> 1.2'
end

group :production, :development do
  gem 'newrelic_rpm'
end

group :development, :personas do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'railroady'
  gem 'rvm-capistrano'
  gem 'statsample'
  gem 'thin', :platform => :mri # web server (Webrick do not support keep-alive connections)
end

group :test, :development, :personas do
#  gem 'database_cleaner'
  gem 'factory_girl', '~> 4.0'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'faraday'
  gem 'guard', '~> 1.3'
  gem 'guard-cucumber', '~> 1.2'
  gem 'guard-rspec', '~> 2.1'
  gem 'guard-spork', '~> 1.1', platform: :mri
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
  platform :mri do
    gem "yard", "~> 0.8.3"
    gem "yard-rest", "~> 1.1.4"
    gem 'redcarpet' # yard-rest dependency
    gem 'therubyracer'
  end
  platform :jruby do
    gem 'therubyrhino'
  end
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller', platform: :mri
  gem 'haml-rails'
  gem 'meta_request'
  gem 'nkss-rails', :git => 'git://github.com/interactivethings/nkss-rails.git'   # CSS styleguides
  gem 'quiet_assets'
  gem 'zencoder-fetcher'
# gem 'rack-mini-profiler'
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'cucumber', '~> 1.2'
  gem 'cucumber-rails', '~> 1.3', :require => false
  gem 'gherkin', '= 2.12.0' # NOTE, CI setup must be adjusted if this is updated !!!
  gem 'launchy'  
  gem 'selenium-webdriver', '~> 2.30'
  gem 'simplecov', '~> 0.6'
  gem 'therubyracer', :platform => :mri
  gem 'therubyrhino', :platform => :jruby
end
