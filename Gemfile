eval_gemfile 'engines/datalayer/Gemfile'

####################################################################
# required in production PRODUCTION
#####################################################################

# Engines
gem 'configuration_management_backdoor', '= 3.0.0'

# API
gem 'responders'

# Webserver
gem 'puma'
# gem 'thin', platform: :mri, group: [:development, :personas]


# ZHDK-INTEGRATION
# gem "madek_zhdk_integration", path: "/Users/thomas/Programming/MADEK/zhdk_integration"
gem 'madek_zhdk_integration', git: 'https://github.com/madek/madek-zhdk-integration.git', ref: '97a961746d357c844b2e2cf53221d337645c660d'

# FRONTEND
gem 'bootstrap-sass'
gem 'browserify-rails', '= 1.0.1'
#gem 'browserify-rails', path: "/Users/thomas/Programming/ROR/browserify-rails"
gem 'coffee-rails'
gem 'compass-rails', '~> 2.0'
gem 'font-awesome-sass'
gem 'haml-lint', '~> 0.10.0'
gem 'haml-rails'
gem 'kramdown'
gem 'react-rails', '~> 1.4.0'
gem 'sass'
gem 'sass-rails'

# The rest
gem 'bcrypt-ruby'
gem 'cider_ci-open_session', '>= 1.0.0', '< 2.0.0'
gem 'execjs'
gem 'exiftool_vendored'
gem 'inshape', '>= 1.0.1', '< 2.0'
gem 'git'
gem 'jruby-openssl', platform: :jruby
gem 'json'
gem 'kaminari'
gem 'nokogiri'
gem 'pundit'
gem 'rails_autolink', '~> 1.0'
gem 'rubyzip'
gem 'therubyracer', platform: :mri
gem 'therubyrhino', platform: :jruby
gem 'uglifier'
gem 'zencoder', '~> 2.4'

####################################################################
# TEST or DEVELOPMENT only
#####################################################################

gem 'better_errors', platform: :mri, group: [:development]
gem 'binding_of_caller', platform: :mri, group: [:development]
gem 'capybara', '~> 2.4', group: [:test]
gem 'meta_request', group: [:development]
gem 'flamegraph', group: [:development], platform: :mri # for mini-profiler
gem 'poltergeist', group: [:test, :development, :personas]
gem 'quiet_assets', group: [:development]
gem 'rack-mini-profiler', group: [:development, :production]
gem 'rest-client', group: [:test, :development, :personas]
gem 'ruby-prof', group: [:development], platform: :mri
gem 'selenium-webdriver', group: [:test]
gem 'zencoder-fetcher', group: [:development]

# TEMPORARILY DISABLED
# gem 'rack-mini-profiler', group: [:development]
#
