# common gems from datalayer, if checked out (otherwise GitHub cant parse this file!)
SHARED_GEMFILE = './datalayer/Gemfile'
eval_gemfile(SHARED_GEMFILE) if File.exists?(SHARED_GEMFILE)

ruby '2.7.2'

####################################################################
# required in production PRODUCTION
#####################################################################

# Engines
gem 'configuration_management_backdoor',
    '= 4.0.0',
    git: 'https://github.com/Madek/rails_configuration-management-backdoor'

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
gem 'mini_racer'
# NOTE: if this fails, maybe try libv8 from source?
# gem "libv8", github: "rubyjs/libv8", submodules: true

# LINKED DATA
gem 'json-ld'
gem 'rdf'
gem 'rdf-rdfxml'
gem 'rdf-turtle'
gem 'equivalent-xml'

# The rest
gem 'cider_ci-open_session', '>= 1.0.0', '< 2.0.0'
gem 'execjs'
gem 'exiftool_vendored'
gem 'git'
gem 'json'
gem 'kaminari'
gem 'pundit'
gem 'rubyzip'
gem 'uglifier'

# fixes
gem 'unf_ext', '>= 0.0.7.4' # indirect dependcy, but define here to force version new enough to run on ARM processors

####################################################################
# TEST or DEVELOPMENT only
#####################################################################

group :test do
  gem 'capybara', '~> 2.18'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end

gem 'poltergeist', groups: [:test, :development]
gem 'rest-client', groups: [:test, :development]

group :development do
  gem 'binding_of_caller'
  gem 'ruby-prof'
  gem 'zencoder-fetcher'
  # gem 'better_errors' # NOTE: including this breaks rails and pry in weird ways…
end
