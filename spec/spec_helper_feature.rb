# frozen_string_literal: true
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

DEFAULT_BROWSER_TIMEOUT = 180 # instead of the default 60
BROWSER_DONWLOAD_DIR = Rails.root.join('tmp', 'test_driver_browser_downloads')
`rm -rf #{BROWSER_DONWLOAD_DIR} && mkdir -p #{BROWSER_DONWLOAD_DIR}`

# set fixed port if given
if ENV['CAPYBARA_SERVER_PORT'].present?
  Capybara.server_port = ENV['CAPYBARA_SERVER_PORT']
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.check_all_pending! if defined?(ActiveRecord::Migration)

def truncate_tables
  PgTasks.truncate_tables
end

FIREFOX_BIN_PATH = Pathname.new(`which firefox`.strip).expand_path.to_s

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = true
  config.order = 'random'

  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(
      app,
      browser: :firefox)
  end

  Capybara.register_driver :selenium_ff do |app|
    create_firefox_driver(app, DEFAULT_BROWSER_TIMEOUT)
  end

  Capybara.register_driver :selenium_ff_nojs do |app|
    create_firefox_driver(app, DEFAULT_BROWSER_TIMEOUT,
                          'general.useragent.override' => 'Firefox NOJSPLZ')
  end

  # Firefox >= 124 auto-accepts `beforeunload` prompts in a WebDriver Classic
  # session. A BiDi session keeps the prompt open so a spec can dismiss or
  # accept it. Only the leave-page specs opt in (`browser: :firefox_bidi`).
  Capybara.register_driver :selenium_ff_bidi do |app|
    create_firefox_driver(app, DEFAULT_BROWSER_TIMEOUT, {}, bidi: true)
  end

  def set_browser(example)
    # default is firefox! rack_test is `browser: false`
    Capybara.current_driver = \
      case example.metadata[:browser]
      when nil, true, :firefox then :selenium_ff
      when false then :rack_test
      when :firefox_nojs then :selenium_ff_nojs
      when :firefox_bidi then :selenium_ff_bidi
      else fail 'unknown browser!'
      end
  end

  def prepare_db(example)
    truncate_tables

    # Restore personas db (specs can disable this by setting the `with_db: false` metadata)
    db_dump_path = Rails.root.join('db', 'personas.pgbin')
    PgTasks.data_restore db_dump_path unless example.metadata[:with_db] == false
  end

  def maximize_window_if_possible
    if Capybara.current_driver.presence_in %i(selenium_ff selenium_ff_nojs selenium_ff_bidi)
      Capybara.page.driver.browser.manage.window.maximize
    end
  end

  config.before(:each) do |example|
    prepare_db(example)
    set_browser(example)
    maximize_window_if_possible
  end

  config.after(:each) do |example|
    unless example.exception.nil?
      take_screenshot
    end
  end

  def wait_until(wait_time = 60, &block)
    begin
      Timeout.timeout(wait_time) do
        until value = yield
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
    name ||= "screenshot_#{Time.zone.now.iso8601.tr(':', '-')}.png"
    Dir.mkdir screenshot_dir rescue nil
    path = screenshot_dir.join(name)
    case Capybara.current_driver
    when :selenium_ff, :selenium_ff_nojs, :selenium_ff_bidi, :selenium_chrome
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

  config.after(:each) do |example|
    if ENV["PRY_ON_EXCEPTION"].present?
      unless example.exception.nil?
        binding.pry
      end
    end
  end

  # BiDi navigation waits until the load completes. An open `beforeunload`
  # prompt blocks that call until read_timeout, including Capybara's session
  # reset. Dismiss a prompt that is already open, then stop the app's
  # listeners so the reset navigation does not open a new one.
  config.after(:each) do
    next unless Capybara.current_driver == :selenium_ff_bidi

    browser = page.driver.instance_variable_get(:@browser)
    next unless browser

    browser.switch_to.alert.dismiss rescue nil
    browser.execute_script(
      "window.addEventListener('beforeunload', e => e.stopImmediatePropagation(), true)"
    )
  rescue StandardError
    nil
  end

end

def create_firefox_driver(app, timeout, extra_profile_config = {}, bidi: false)
  dont_ask_on_downloads_config = { #
    'browser.helperApps.neverAsk.saveToDisk' => 'image/jpeg,application/pdf',
    'browser.download.manager.showWhenStarting' => false,
    'browser.download.folderList' => 2, # custom location
    'browser.download.dir' => BROWSER_DONWLOAD_DIR.to_s,
    'devtools.jsonview.enabled' => false, # prevent firefox from pretty-printing JSON response
    'dom.disable_beforeunload' => false
  }
  profile_config = dont_ask_on_downloads_config.merge(extra_profile_config)

  profile = Selenium::WebDriver::Firefox::Profile.new
  profile_config.each { |k, v| profile[k] = v }

  option_args = { profile: profile, binary: FIREFOX_BIN_PATH }
  if bidi
    option_args[:web_socket_url] = true
    # `beforeUnload: ignore` is what leaves the prompt open. The default still
    # dismisses alert/confirm/prompt dialogs.
    option_args[:unhandled_prompt_behavior] = {
      beforeUnload: 'ignore',
      default: 'dismiss and notify'
    }
  end
  opts = Selenium::WebDriver::Firefox::Options.new(**option_args)

  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = timeout
  Capybara::Selenium::Driver.new \
    app, browser: :firefox, options: opts, http_client: client
end

require 'spec_helper_feature_shared'
