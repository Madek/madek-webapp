ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'capybara/poltergeist'


Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

def truncate_tables
  DBHelper.truncate_tables
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true
  config.order = "random"

  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :poltergeist_debug do |app|
    Capybara::Poltergeist::Driver.new(app, :inspector => true)
  end

  Capybara.current_driver = :selenium

  def set_browser example
    case example.metadata[:browser]
    when :chrome
      Capybara.current_driver = :selenium_chrome
    when :headless, :jsbrowser
      Capybara.current_driver = :poltergeist
    when :rack_test
      Capybara.current_driver = :rack_test
    when :firefox
      Capybara.current_driver = :selenium
    else
      Capybara.current_driver = :rack_test
    end
  end

  config.before(:each) do 
    truncate_tables
    DBHelper.load_data Rails.root.join('db','personas.data.psql')
    set_browser(example)
  end

end

require 'spec_helper_feature_shared'
