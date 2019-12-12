eval_gemfile Pathname(File.dirname(File.absolute_path(__FILE__))).join('datalayer', 'Gemfile')

ruby '2.6.3'

####################################################################
# required in production PRODUCTION
#####################################################################

# Engines
gem 'configuration_management_backdoor', '= 4.0.0', git: 'https://github.com/michalpodlecki/rails_configuration-management-backdoor'

# API
gem 'responders'

# Webserver
gem 'puma'

# ZHDK-INTEGRATION
gem "madek_zhdk_integration", path: "zhdk-integration"

# FRONTEND
gem 'compass-rails', '~> 3.0'
gem 'haml-rails'
gem 'kramdown'
gem 'react-rails', '= 1.9.0'
gem 'sass'
gem 'sass-rails'
gem 'coffee-rails'

# LINKED DATA
gem 'linkeddata'
gem 'json-ld'
gem 'rdf'
gem 'rdf-rdfxml'
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

gem 'binding_of_caller', platform: :mri, group: [:development]
gem 'capybara', '~> 2.4', group: [:test]
gem 'poltergeist', group: [:test, :development, :personas]
gem 'rest-client', group: [:test, :development, :personas]
gem 'ruby-prof', group: [:development], platform: :mri
gem 'selenium-webdriver', group: [:test]
gem 'zencoder-fetcher', group: [:development]
gem 'rails-controller-testing', group: :test
