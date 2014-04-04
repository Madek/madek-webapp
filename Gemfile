
# Otherwise Passenger/Rack throws a hissy fit
# http://stackoverflow.com/questions/8252160/invalid-byte-sequence-error-in-normalize-yaml-input-being-thrown
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

source 'http://rubygems.org'
source 'http://gems.github.com'

# RAILS
gem 'rails', '4.0.3'


# DATABASE
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
gem 'composite_primary_keys', "~> 6.0"
gem 'foreigner'
gem 'jdbc-postgres', platform: :jruby
gem 'memcache-client' 
gem 'pg', platform: :mri
gem 'textacular', git: 'https://github.com/DrTom/textacular.git'

# API 
gem 'roar'
gem 'kramdown'
gem 'roar-rails'

# THE REST
gem 'animation'
gem 'bcrypt-ruby', '~> 3.1.2'
gem 'better_errors', group: [:development]
gem 'binding_of_caller', platform: :mri, group: [:development]
gem 'bootstrap-sass' 
gem 'capistrano', group: [:development, :personas]
gem 'capistrano-ext', group: [:development, :personas]
gem 'capybara', '1.1.2', group: [:test]
gem 'coffee-rails'
gem 'coffee-script'
gem 'compass-rails', github: "Compass/compass-rails", branch: "rails4-hack"
gem 'cucumber', '~> 1.2', group: [:test]
gem 'cucumber-rails', '~> 1.3', :require => false, group: [:test]
gem 'dalli'
gem 'execjs'
gem 'factory_girl', group: [:test, :development, :personas]
gem 'factory_girl_rails', group: [:test, :development, :personas]
gem 'faker', group: [:test, :development, :personas]
gem 'font-awesome-sass'
gem 'gettext_i18n_rails'
gem 'gherkin',  group: [:test] 
gem 'git'
gem 'haml'
gem 'haml-rails', group: [:development]
gem 'haml_assets'
gem 'haml_coffee_assets'
gem 'jquery-rails'
gem 'jquery-tmpl-rails'
gem 'jquery-ui-rails'
gem 'jruby-openssl', :platform => :jruby
gem 'json'
gem 'kaminari'
gem 'meta_request', group: [:development]
gem 'net-ldap', :require => 'net/ldap', :git => 'git://github.com/justcfx2u/ruby-net-ldap.git'
gem 'newrelic_rpm', group: [:production, :development]
gem 'nokogiri'
gem 'poltergeist', group: [:test, :development, :personas]
gem 'pry', group: [:test, :development]
gem 'pry-nav', group: [:test, :development]
gem 'quiet_assets', group: [:development]
gem 'rails_autolink', '~> 1.0'
gem 'rest-client', group: [:test, :development, :personas]
gem 'rspec-rails', group: [:test, :development, :personas]
gem 'rvm-capistrano', group: [:development, :personas]
gem 'sass-rails', '~> 4.0.1'
gem 'sass', '3.2.12'
gem 'selenium-webdriver', group: [:test]
gem 'therubyracer', platform: :mri, group: [:development, :production, :test]
gem 'therubyrhino', platform: :jruby, group: [:development, :production, :test]
gem 'thin', :platform => :mri, group: [:development, :personas] # web server (Webrick do not support keep-alive connections)
gem 'uglifier', '~> 1.3'
gem 'uuidtools'
gem 'zencoder', '~> 2.4'
gem 'zencoder-fetcher', group: [:development]
gem 'rubyzip'



# TEMPORARILY DISABLED
 
# gem "yard", "~> 0.8.3", platform: :mri, group: [:development, :production]
# gem "yard-rest", "~> 1.1.4", platform: :mri, group: [:development, :production]
# gem 'rack-mini-profiler', group: [:development]
# gem 'redcarpet', platform: :mri, group: [:development, :production] # yard-rest dependency


