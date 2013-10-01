Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = ENV['CAPYBARA_WAIT_TIME'].try(:to_i) || 10

require 'capybara/poltergeist'

Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, :inspector => true)
end

Before('@jsbrowser') do 
  Capybara.current_driver = :poltergeist
end

After('@jsbrowser') do
  Capybara.use_default_driver
end


# poltergeist_debug
# see https://github.com/jonleighton/poltergeist
# http://www.jonathanleighton.com/articles/2012/poltergeist-0-6-0/
Before('@poltergeist_debug') do 
  Capybara.current_driver = :poltergeist_debug
end

After('@poltergeist_debug') do
  Capybara.use_default_driver
end

# Firefox
Before('@firefox') do |scenario|
    Capybara.current_driver = :selenium
end
After('@firefox') do |scenario|
    Capybara.use_default_driver
end


Before('@chrome') do |scenario|
  Capybara.current_driver = :selenium_chrome
end
After('@chrome') do |scenario|
  Capybara.use_default_driver
end


Before('@encoding') do
  # let's wake up test
  `curl -I http://test.madek.zhdk.ch/`

  @run_server = Capybara.run_server
  Capybara.run_server = false

  @default_host =  Capybara.app_host
  Capybara.app_host = 'http://test.madek.zhdk.ch'
end
 
After('@encoding') do
  Capybara.run_server = @run_server
  Capybara.app_host = @default_host
end



# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css


