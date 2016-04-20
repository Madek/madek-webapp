ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

require 'capybara/poltergeist'

DEFAULT_BROWSER_TIMEOUT = 180 # instead of the default 60

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

def truncate_tables
  PgTasks.truncate_tables
end

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true
  config.order = 'random'

  config.include FavoriteHelper
  config.include SelectCollectionHelper

  if ENV['FIREFOX_ESR_PATH'].present?
    Selenium::WebDriver::Firefox.path = ENV['FIREFOX_ESR_PATH']
  end

  Capybara.register_driver :selenium_ff do |app|
    create_firefox_driver(app, DEFAULT_BROWSER_TIMEOUT)
  end

  Capybara.register_driver :selenium_ff_nojs do |app|
    create_firefox_driver(app, DEFAULT_BROWSER_TIMEOUT,
                          'general.useragent.override' => 'Firefox NOJSPLZ')
  end

  def set_browser(example)
    case example.metadata[:browser]
    when :firefox
      Capybara.current_driver = :selenium_ff
    when :firefox_nojs
      Capybara.current_driver = :selenium_ff_nojs
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

  def wait_until(wait_time = 60, &block)
    begin
      Timeout.timeout(wait_time) do
        until value = block.call
          sleep(1)
        end
        value
      end
    rescue Timeout::Error => _e
      fail Timeout::Error.new(block.source), 'It timed out!'
    end
  end

  def take_screenshot(screenshot_dir = nil, name = nil)
    screenshot_dir ||= Rails.root.join('tmp', 'capybara')
    name ||= "screenshot_#{Time.zone.now.iso8601.gsub(/:/, '-')}.png"
    Dir.mkdir screenshot_dir rescue nil
    path = screenshot_dir.join(name)
    case Capybara.current_driver
    when :selenium_ff, :selenium_ff_nojs, :selenium_chrome
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

def create_firefox_driver(app, timeout, profileConfig = {})
  profile = Selenium::WebDriver::Firefox::Profile.new
  profileConfig.each { |k, v| profile[k] = v }
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = timeout
  Capybara::Selenium::Driver.new \
    app, browser: :firefox, profile: profile, http_client: client
end

require 'spec_helper_feature_shared'
