SHARED_GEMFILE = './datalayer/Gemfile'
eval_gemfile(SHARED_GEMFILE) if File.exist?(SHARED_GEMFILE)

####################################################################
# required in production PRODUCTION
#####################################################################

# Engines
gem 'configuration_management_backdoor',
    git: 'https://github.com/Madek/rails_configuration-management-backdoor', branch: 'rails7'

# API
gem 'responders'

# Webserver
gem 'puma', '~> 6.4'
gem 'puma_worker_killer'

# FRONTEND
gem 'haml-rails'
gem 'kramdown'
gem 'react-rails', '= 1.10.0'
gem 'sass'
gem 'sass-rails'
gem 'sprockets-rails', '>= 3.5'

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
gem 'git', '~> 1.13'
gem 'json'
gem 'kaminari'
gem 'pundit'
gem 'rubyzip', '~> 1.0'
gem 'sitemap_generator'
gem 'sorted_set'
gem 'uglifier'


####################################################################
# TEST or DEVELOPMENT only
#####################################################################

group :test do
  gem 'capybara', '~> 3.8'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end

gem 'rest-client', groups: [:test, :development]

group :development do
  # gem 'binding_of_caller'
  # gem 'ruby-prof'
  gem 'zencoder-fetcher'
  # gem 'better_errors' # NOTE: including this breaks rails and pry in weird ways…
  # gem 'rack-mini-profiler'
end
