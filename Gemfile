eval_gemfile Pathname(File.dirname(File.absolute_path(__FILE__))).join('datalayer', 'Gemfile')

####################################################################
# required in production PRODUCTION
#####################################################################

# Engines
gem 'configuration_management_backdoor', '= 3.0.0'

# API
gem 'responders'

# Webserver
gem 'puma'

# ZHDK-INTEGRATION
gem "madek_zhdk_integration", path: "zhdk-integration"

# FRONTEND
gem 'compass-rails', '~> 2.0'
gem 'haml-rails'
gem 'kramdown'
gem 'react-rails', '~> 1.7.1'
gem 'sass'
gem 'sass-rails'

# LINKED DATA
gem 'linkeddata'
gem 'json-ld'
gem 'rdf'
gem 'rdf-rdfxml'
gem 'equivalent-xml'
gem 'nokogiri'

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
gem 'pundit'
gem 'rails_autolink', '~> 1.0'
gem 'rubyzip'
gem 'therubyracer', platform: :mri
gem 'therubyrhino', platform: :jruby
gem 'uglifier'

####################################################################
# TEST or DEVELOPMENT only
#####################################################################

gem 'better_errors', platform: :mri, group: [:development]
gem 'binding_of_caller', platform: :mri, group: [:development]
gem 'capybara', '~> 2.4', group: [:test]
gem 'meta_request', group: [:development]
gem 'poltergeist', group: [:test, :development, :personas]
gem 'quiet_assets', group: [:development]
gem 'rest-client', group: [:test, :development, :personas]
gem 'ruby-prof', group: [:development], platform: :mri
gem 'selenium-webdriver', group: [:test]
gem 'zencoder-fetcher', group: [:development]
