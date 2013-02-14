Capybara.javascript_driver = :poltergeist
Capybara.default_wait_time = 3

require 'capybara/poltergeist'

Capybara.register_driver :selenium_chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
end


Before('@jsbrowser') do 
  Capybara.current_driver = :poltergeist
end

After('@jsbrowser') do
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




# Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
# order to ease the transition to Capybara we set the default here. If you'd
# prefer to use XPath just remove this line and adjust any selectors in your
# steps to use the XPath syntax.
Capybara.default_selector = :css


