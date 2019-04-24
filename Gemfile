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

# LINKED DATA
# WTF: including this breaks Active record o_O - check with `bin/rails runner 'puts UsageTerms.most_recent.id === nil'` => true!
# gem 'linkeddata'
gem 'json-ld'
gem 'rdf'
gem 'rdf-rdfxml'
gem 'rdf-turtle'
gem 'equivalent-xml'

# The rest
gem 'bcrypt-ruby'
gem 'cider_ci-open_session', '>= 1.0.0', '< 2.0.0'
gem 'execjs'
gem 'exiftool_vendored'
gem 'git'
gem 'json'
gem 'kaminari'
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
  # gem 'better_errors' # NOTE: including this breaks rails and pry in weird ways…
  gem 'binding_of_caller'
end
