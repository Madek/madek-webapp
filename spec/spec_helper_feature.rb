ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

require 'capybara/poltergeist'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

def truncate_tables
  PgTasks.truncate_tables
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true
  config.order = 'random'

  if ENV['FIREFOX_ESR_PATH'].present?
    Selenium::WebDriver::Firefox.path = ENV['FIREFOX_ESR_PATH']
  end

  Capybara.register_driver :selenium_ff do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 180 # instead of the default 60
    Capybara::Selenium::Driver.new \
      app, browser: :firefox, profile: profile, http_client: client
  end

  def set_browser(example)
    case example.metadata[:browser]
    when :firefox
      Capybara.current_driver = :selenium_ff
    when :phantomjs
      Capybara.current_driver = :poltergeist
    else
      Capybara.current_driver = :rack_test
    end
  end

  config.before(:each) do |example|
    truncate_tables
    PgTasks.data_restore Rails.root.join('db', 'personas.pgbin')
    set_browser(example)
  end

  config.after(:each) do |example|
    unless example.exception.nil?
      take_screenshot
    end
  end

  def take_screenshot(screenshot_dir = nil, name = nil)
    screenshot_dir ||= Rails.root.join('tmp', 'capybara')
    name ||= "screenshot_#{Time.zone.now.iso8601.gsub(/:/, '-')}.png"
    Dir.mkdir screenshot_dir rescue nil
    path = screenshot_dir.join(name)
    case Capybara.current_driver
    when :selenium_ff, :selenium_chrome
      page.driver.browser.save_screenshot(path) rescue nil
    when :poltergeist
      page.driver.render(path, full: true) rescue nil
    else
      Rails
        .logger
        .warn "Taking screenshots is not implemented for \
              #{Capybara.current_driver}."
    end
  end

  # useful for debugging tests:
  # config.after(:each) do |example|
  #   unless example.exception.nil?
  #     binding.pry
  #   end
  # end

end

require 'spec_helper_feature_shared'
