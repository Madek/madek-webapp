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
gem 'pg_tasks', '>= 1.2.0', '< 2.0.0'
gem 'textacular', git: 'https://github.com/DrTom/textacular.git'

# API
gem 'kramdown'
gem 'roar'
gem 'roar-rails'

# ZHDK-INTEGRATION
# gem "madek_zhdk_integration", path: "../zhdk_integration"
gem 'madek_zhdk_integration', git: 'https://github.com/zhdk/madek-zhdk-integration.git'

# FRONTEND
gem 'bootstrap-sass'
gem 'coffee-rails'
gem 'coffee-script'
gem 'compass-rails', '~> 2.0'
gem 'font-awesome-sass'
gem 'haml'
gem 'haml-lint', '~> 0.10.0'
gem 'haml-rails'
gem 'haml_assets'
gem 'jquery-rails'
gem 'jquery-tmpl-rails'
gem 'jquery-ui-rails'
gem 'sass'
gem 'sass-rails'

# The rest
gem 'bcrypt-ruby'
gem 'dalli'
gem 'execjs'
gem 'gettext_i18n_rails'
gem 'git'
gem 'jruby-openssl', platform: :jruby
gem 'json'
gem 'kaminari'
gem 'newrelic_rpm', group: [:production, :development]
gem 'nokogiri'
gem 'rails_autolink', '~> 1.0'
gem 'rails_config'
gem 'rubyzip'
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
gem 'simplecov-html', require: false, group: ['test'],
                      git: 'https://github.com/eins78/simplecov-html.git',
                      ref: '3fac7b20bbe3967d1f9d55c3166f348d620a2005'
                      # path: '/Users/ma/CODE/simplecov-html'
# web server (Webrick do not support keep-alive connections)
gem 'thin', platform: :mri, group: [:development, :personas]
gem 'zencoder-fetcher', group: [:development]

gem 'cider_ci-support', '= 1.1.0', group: [:development, :test]
# gem 'cider_ci-support', path: '/Users/thomas/Programming/CIDER-CI/ruby_support'
gem 'cider_ci-rspec_support', '>= 1.0.3', '< 2.0.0', group: [:development, :test]
# gem 'cider_ci-rspec_support', path: '/Users/thomas/Programming/CIDER-CI/ruby-rspec-support'


# TEMPORARILY DISABLED
# gem 'rack-mini-profiler', group: [:development]
#
