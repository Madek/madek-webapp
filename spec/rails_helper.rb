# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/poltergeist'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!

def truncate_tables
  DBHelper.truncate_tables
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :poltergeist_debug do |app|
    Capybara::Poltergeist::Driver.new(app, :inspector => true)
  end

  Capybara.current_driver = :selenium
  Capybara.default_wait_time = 5

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

  config.before(:each) do |example|
    truncate_tables
    DBHelper.load_data Rails.root.join('db','personas.data.psql')
    set_browser(example)
  end

  config.after(:each) do |example|
    if example.exception != nil
      take_screenshot
    end
  end

  def take_screenshot
    @screenshot_dir ||= Rails.root.join("tmp","capybara")
    Dir.mkdir @screenshot_dir rescue nil
    path= @screenshot_dir.join("screenshot_#{Time.zone.now.iso8601.gsub(/:/,'-')}.png")
    case Capybara.current_driver
    when :selenium, :selenium_chrome
      page.driver.browser.save_screenshot(path) rescue nil
    when :poltergeist
      page.driver.render(path, :full => true) rescue nil
    else
      Rails.logger.warn "Taking screenshots is not implemented for #{Capybara.current_driver}."
    end
  end

  config.include UIHelpers
  config.include WaitForAjax
end
