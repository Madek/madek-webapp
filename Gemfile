source 'http://rubygems.org'
source 'http://gems.github.com'

####################################################################
# required in production PRODUCTION
#####################################################################

# RAILS
gem 'rails', '4.1.8'

# DATABASE
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
gem 'foreigner'
gem 'jdbc-postgres', platform: :jruby
gem 'memcache-client'
gem 'pg', platform: :mri
gem 'textacular', git: 'https://github.com/DrTom/textacular.git'

# API
gem 'kramdown'
gem 'roar'
gem 'roar-rails'

# ZHDK-INTEGRATION
# gem "madek_zhdk_integration", path: "../zhdk_integration"
gem 'madek_zhdk_integration', git: 'https://github.com/zhdk/madek-zhdk-integration.git', ref: '11434aeea50795c0a8e5663b4350746232744319'

# The rest
gem 'bcrypt-ruby'
gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'coffee-script'
gem 'dalli'
gem 'execjs'
gem 'font-awesome-sass'
gem 'gettext_i18n_rails'
gem 'git'
gem 'haml'
gem 'haml-rails'
gem 'haml_assets'
gem 'haml_coffee_assets'
gem 'jquery-rails'
gem 'jquery-tmpl-rails'
gem 'jquery-ui-rails'
gem 'jruby-openssl', platform: :jruby
gem 'json'
gem 'kaminari'
gem 'newrelic_rpm', group: [:production, :development]
gem 'nokogiri'
gem 'rails_autolink', '~> 1.0'
gem 'rails_config'
gem 'rubyzip'
gem 'sass'
gem 'sass-rails'
gem 'therubyracer', platform: :mri
gem 'therubyrhino', platform: :jruby
gem 'uglifier'
gem 'uuidtools'
gem 'zencoder', '~> 2.4'

####################################################################
# TEST or DEVELOPMENT only
#####################################################################

gem 'better_errors', platform: :mri, group: [:development]
gem 'binding_of_caller', platform: :mri, group: [:development]
gem 'capybara', '~> 2.4', group: [:test]
gem 'factory_girl', group: [:test, :development, :personas]
gem 'factory_girl_rails', group: [:test, :development, :personas]
gem 'faker', group: [:test, :development, :personas]
gem 'meta_request', group: [:development]
gem 'poltergeist', group: [:test, :development, :personas]
gem 'pry', group: [:test, :development]
gem 'pry-nav', group: [:test, :development]
gem 'quiet_assets', group: [:development]
gem 'rest-client', group: [:test, :development, :personas]
gem 'rspec-rails', '~> 3.1', group: [:test, :development]
gem 'rubocop', require: false
gem 'selenium-webdriver', group: [:test]
gem 'simplecov', require: false, group: ['test']
gem 'thin', platform: :mri, group: [:development, :personas] # web server (Webrick do not support keep-alive connections)
gem 'zencoder-fetcher', group: [:development]

gem 'cider_ci-support', '= 1.0.0.pre.beta.3', group: [:development, :test]
# gem 'cider_ci-support', path: '/Users/thomas/Programming/CIDER-CI/ruby_support'

# TEMPORARILY DISABLED
# gem 'rack-mini-profiler', group: [:development]
#
