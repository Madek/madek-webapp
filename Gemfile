# common gems from datalayer, if checked out (otherwise GitHub cant parse this file!)
SHARED_GEMFILE = './datalayer/Gemfile'
eval_gemfile(SHARED_GEMFILE) if File.exists?(SHARED_GEMFILE)

ruby '2.6.6'

####################################################################
# required in production PRODUCTION
#####################################################################

# Engines
gem 'configuration_management_backdoor',
    '= 4.0.0',
    git: 'https://github.com/michalpodlecki/rails_configuration-management-backdoor'

# API
gem 'responders'

# Webserver
gem 'puma'

# ZHDK-INTEGRATION
gem 'madek_zhdk_integration', path: 'zhdk-integration'

# FRONTEND
gem 'compass-rails', '~> 3.0'
gem 'haml-rails'
gem 'kramdown'
gem 'react-rails', '= 1.9.0'
gem 'sass'
gem 'sass-rails'
gem 'coffee-rails'

# The rest
gem 'bcrypt-ruby'
gem 'cider_ci-open_session', '>= 1.0.0', '< 2.0.0'
gem 'execjs'
gem 'exiftool_vendored'
gem 'git'
gem 'json'
gem 'kaminari'
gem 'nokogiri'
gem 'pundit'
gem 'rubyzip'
gem 'therubyracer', platform: :mri
gem 'uglifier'

####################################################################
# TEST or DEVELOPMENT only
#####################################################################

gem 'capybara', '~> 2.4', group: %i[test]
gem 'poltergeist', group: %i[test development personas]
gem 'rest-client', group: %i[test development personas]
gem 'ruby-prof', group: %i[development], platform: :mri
gem 'selenium-webdriver', group: %i[test]
gem 'zencoder-fetcher', group: %i[development]
gem 'rails-controller-testing', group: :test

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end
