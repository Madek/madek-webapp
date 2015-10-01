source 'http://rubygems.org'

####################################################################
# required in production PRODUCTION
#####################################################################

# RAILS
gem 'rails', '~> 4.2'

# Engines
gem 'configuration_management_backdoor', '>= 1.0.0', '< 2.0'

# DATABASE
gem 'activerecord-jdbcpostgresql-adapter', platform: :jruby
gem 'jdbc-postgres', platform: :jruby
gem 'pg', platform: :mri
gem 'pg_tasks', '>= 1.3.3', '< 2.0.0'
# gem "pg_tasks", path: "/Users/thomas/Programming/ROR/pg_tasks"

# API
gem 'responders'


# Webserver
gem 'puma'
# gem 'thin', platform: :mri, group: [:development, :personas]


# ZHDK-INTEGRATION
# gem "madek_zhdk_integration", path: "/Users/thomas/Programming/MADEK/zhdk_integration"
gem 'madek_zhdk_integration', git: 'https://github.com/madek/madek-zhdk-integration.git', ref: '08d45400baa15ffe94c5bca4fadfd95b5ccea8f1'
gem 'textacular', git: 'https://github.com/DrTom/textacular.git'

# FRONTEND
gem 'bootstrap-sass'
gem 'browserify-rails', '= 1.0.1'
#gem 'browserify-rails', path: "/Users/thomas/Programming/ROR/browserify-rails"
gem 'coffee-rails'
gem 'compass-rails', '~> 2.0'
gem 'font-awesome-sass'
gem 'haml'
gem 'haml-lint', '~> 0.10.0'
gem 'haml-rails'
gem 'haml_assets'
gem 'kramdown'
gem 'react-rails', '~> 1.0'
gem 'sass'
gem 'sass-rails'

# The rest
gem 'bcrypt-ruby'
gem 'chronic_duration'
gem 'cider_ci-open_session', '>= 1.0.0', '< 2.0.0'
gem 'dalli'
gem 'execjs'
gem 'exiftool_vendored'
gem 'git'
gem 'jruby-openssl', platform: :jruby
gem 'json'
gem 'kaminari'
gem 'nokogiri'
gem 'pundit'
gem 'rails_autolink', '~> 1.0'
gem 'rails_config', git: 'https://github.com/DrTom/rails_config.git', ref: 'master'
gem 'rubyzip'
gem 'strong_password'
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
gem 'faker', group: [:test, :development, :personas]
gem 'meta_request', group: [:development]
gem 'flamegraph', group: [:development], platform: :mri # for mini-profiler
gem 'poltergeist', group: [:test, :development, :personas]
gem 'pry', group: [:test, :development]
gem 'pry-nav', group: [:test, :development]
gem 'pry-rails', group: [:development]
gem 'quiet_assets', group: [:development]
gem 'rack-mini-profiler', group: [:development] # TODO: staging?
gem 'rest-client', group: [:test, :development, :personas]
gem 'rspec-rails', '~> 3.1', group: [:test, :development]
gem 'rubocop', '= 0.29.1', require: false
gem 'ruby-prof', group: [:development], platform: :mri
gem 'selenium-webdriver', group: [:test]
gem 'simplecov', '>= 0.10',  require: false, group: ['test']
#gem 'simplecov-html', require: false, group: ['test'], git: 'https://github.com/eins78/simplecov-html.git', ref: '3fac7b20bbe3967d1f9d55c3166f348d620a2005'
                      # path: '/Users/ma/CODE/simplecov-html'
gem 'zencoder-fetcher', group: [:development]

gem 'cider_ci-support', '= 2.0.0.pre.beta.2', group: [:development, :test]
# gem 'cider_ci-support', path: '/Users/thomas/Programming/CIDER-CI/ruby_support'

# gem 'cider_ci-rspec_support', '>= 1.0.4', '< 2.0.0', group: [:development, :test]
# gem 'cider_ci-rspec_support', path: '/Users/thomas/Programming/CIDER-CI/ruby-rspec-support'


# TEMPORARILY DISABLED
# gem 'rack-mini-profiler', group: [:development]
#
