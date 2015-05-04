ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

RSpec.configure do |config|

  config.use_transactional_fixtures = false

  config.before(:each) do |example|
    PgTasks.truncate_tables
    PgTasks.data_restore Rails.root.join('db', 'personas.pgbin')
  end

end
