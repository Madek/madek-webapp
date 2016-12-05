# frozen_string_literal: true
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

require 'capybara/poltergeist'

DEFAULT_BROWSER_TIMEOUT = 180 # instead of the default 60
BROWSER_DONWLOAD_DIR = Rails.root.join('tmp', 'test_driver_browser_downloads')
`rm -rf #{BROWSER_DONWLOAD_DIR} && mkdir -p #{BROWSER_DONWLOAD_DIR}`

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
    create_firefox_driver(app, DEFAULT_BROWSER_TIMEOUT)
  end

  Capybara.register_driver :selenium_ff_nojs do |app|
    create_firefox_driver(app, DEFAULT_BROWSER_TIMEOUT,
                          'general.useragent.override' => 'Firefox NOJSPLZ')
  end

  def set_browser(example)
    # default is firefox! rack_test is `browser: false`
    Capybara.current_driver = \
      case example.metadata[:browser]
      when nil, true, :firefox then :selenium_ff
      when false then :rack_test
      when :firefox_nojs then :selenium_ff_nojs
      when :phantomjs then :poltergeist
      else fail 'unknown browser!'
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

  # fail example if there were any (unexpected) JS errors
  config.after(:each) do |example|
    # examples can EXPECT ERRORS, e.g. for testing if this setup still works
    expected_errors = example.metadata[:expect_js_errors] || []

    # list of always allowed/expected JS errors:
    whitelist = [
      'mutating the [[Prototype]] of an object', # from browserify-buffer. it's ok.
      # NOTE: doesn't break anything, will fix itself when there is only 1 root
      'facebook.github.io/react/docs/error-decoder.html?invariant=32&args[]=2'
    ]

    if page.driver.to_s =~ /Selenium/
      errors = wait_until(30) do # need to wait for window.onLoad event…
        begin
          page.execute_script('return window.JSErrorCollector_errors.pump()')
        rescue
          false
        end
      end

      actual_errors = errors.reject do |e|
        next true if e['sourceName'].empty? # only care about our own scripts
        whitelist.map { |w| e['errorMessage'].match Regexp.escape(w) }.compact.any?
      end

      unexpected_errors = actual_errors.reject do |e|
        expected_errors
          .map { |w| e['errorMessage'].match Regexp.escape(w) }.compact.any?
      end

      if unexpected_errors.any?
        fail 'UNEXPECTED JS ERRORS! ⚡️  ' + JSON.pretty_generate(actual_errors)
      end

      if expected_errors.any?
        if expected_errors.length != (actual_errors - unexpected_errors).length
          fail "\
            MISSING EXPECTED JS ERRORS! \n\
            (This likely means the error-detecting setup is broken!)\n\n\
            Expected: ".strip_heredoc + JSON.pretty_generate(expected_errors) +
            "\nActual: " + JSON.pretty_generate(actual_errors)
        end
      end
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

def create_firefox_driver(app, timeout, extra_profile_config = {})
  dont_ask_on_downloads_config = { #
    'browser.helperApps.neverAsk.saveToDisk' => 'image/jpeg,application/pdf',
    'browser.download.manager.showWhenStarting' => false,
    'browser.download.folderList' => 2, # custom location
    'browser.download.dir' => BROWSER_DONWLOAD_DIR.to_s
  }
  profile_config = dont_ask_on_downloads_config.merge(extra_profile_config)

  profile = Selenium::WebDriver::Firefox::Profile.new
  profile_config.each { |k, v| profile[k] = v }

  # we need a firefox extension to collect javascript errors
  # see https://github.com/mguillem/JSErrorCollector
  profile.add_extension File.join(Rails.root, 'spec/_support/JSErrorCollector.xpi')

  client = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout = timeout
  Capybara::Selenium::Driver.new \
    app, browser: :firefox, profile: profile, http_client: client
end

require 'spec_helper_feature_shared'
