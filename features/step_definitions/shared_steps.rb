# The common steps are lexically ordered. 
# PLEASE KEEP IT THIS WAY!
#

### I a... #########################################

Given /^I accept the usage terms if I am supposed to do so$/ do
  if all("h3",text: "Nutzungsbedingungen").size > 0
    find("button",text: "Akzeptieren").click
  end
end

Then /^I am able to leave the page$/ do
  @current_path.should_not eq page.current_path
end

Then /^I am on the page of the resource$/ do
  case @resource.type
  when "MediaSet" 
    expect(current_path).to eq media_set_path @resource
  when "MediaEntry" 
    expect(current_path).to eq media_entry_path @resource
  else
    raise
  end
end


Then /^I am on the "(.*?)" page$/ do |path|
  expect(current_path).to eq path
end

Given /^I am signed\-in as "(.*?)"$/ do |login|
  visit "/"
  find("a#database-user-login-tab").click
  find("input[name='login']").set(login)
  find("input[name='password']").set('password')
  find("button[type='submit']").click
  @me = @current_user = User.find_by_login login
end



### I c⋯ #########################################

Then /^I can see the text "(.*?)"$/ do |text|
  expect(page).to have_content text
end

Then(/^I can see a success message$/) do
  expect(all("#messages .alert-success").size).to be > 0
end

When /^I change some input field$/ do
  find("input[type=text]").set "123"
end

When /^I click on the link "(.*?)"$/ do |link_text|
  wait_until{ all("a", text: link_text, visible: true).size > 0}
  find("a",text: link_text).click
end 

When /^I click on the link "(.*?)" inside of the dialog$/ do |link_text|
  step 'I wait for the dialog to appear'
  find("a",text: link_text).click
end

When /^I click on "(.*?)" inside the autocomplete list$/ do |text|
  wait_until{  all("ul.ui-autocomplete li").size > 0 }
  find("ul.ui-autocomplete li a",text: text).click
end

When /^I click on the button "(.*?)"$/ do |button_text|
  wait_until{all("button:not([disabled])", text: button_text).size > 0 }
  find("button:not([disabled])",text: button_text).click
end

When(/^I click on "(.*?)"$/) do |text|
  wait_until{ all("a, button", text: text, visible: true).size > 0}
  find("a, button",text: text).click
end

When /^I click the primary action of this dialog$/ do
  find(".ui-modal .primary-button").click
end

When /^I click the submit input$/ do
  find("input[type='submit']").click
end

When /^I click on the submit button$/ do
  find("button[type='submit']").click
end

Given /^I close the modal dialog\.$/ do
  find(".modal a[data-dismiss='modal']").click
  wait_until(2){all(".modal-backdrop").size == 0}
end

And /^I confirm the browser dialog$/ do
  unless Capybara.current_driver == :poltergeist
    page.driver.browser.switch_to.alert.accept 
  end
end

### I f⋯ ###################################################

When /^(?:|I )fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    step %{I fill in "#{name}" with "#{value}"}
  end
end

When /^I follow the link with the text "(.*?)"$/ do |text|
  find("a",text: text).click
end

Given /^I logout\.$/ do
  find(".app-header .ui-header-user a").click
  find("a[href='/logout']").click
end

### I h⋯ ###################################################

Then /^I have to confirm$/ do
  unless Capybara.current_driver == :poltergeist
    page.driver.browser.switch_to.alert.accept 
  end
end

### I o⋯ ###################################################

When /^I open the organize dialog$/ do
  wait_until {all(".app[data-id]").size > 0}
  find(".ui-body-title-actions .primary-button").click
  wait_until {all(".ui-drop-item a[data-organize-arcs]", :visible => true).size > 0}
  all(".ui-drop-item a[data-organize-arcs]", :visible => true).first.click
  step 'I wait for the dialog to appear'
end

### I p⋯ ###################################################

When /^I pry$/ do
  binding.pry 
end

### I s⋯ ###################################################

Then /^I see an error alert$/ do
  expect{ find(".ui-alert.error",visible: true) }.not_to raise_error
end

Then /^I see a confirmation alert$/ do
  expect{ find(".ui-alert.confirmation",visible: true) }.not_to raise_error
end

Then /^I see a warning that I will lose unsaved data$/ do
  page.driver.browser.switch_to.alert.text.should =~ /Nicht gespeicherte Daten gehen verloren/
end

Then /^I select "(.*?)" from "(.*?)"$/ do |text, class_name|
  find("select.#{class_name}").select(text)
end

When /^I set the input with the name "(.*?)" to "(.*?)"$/ do |name, value|
  find("input[name='#{name}']").set(value)
  # page.execute_script %Q{ $("input[name='#{name}']").trigger("change") }
end

Given /^I set the autocomplete\-input with the name "(.*?)" to "(.*?)"$/ do |name, value|
  find("input[name='#{name}']").set(value)
  page.execute_script %Q{ $("input[name='#{name}']").trigger("change") }
end

Given /^I set the input with the name "(.*?)" to "(.*?)" and submit$/ do |name, value|
  find("input[name='#{name}']").set(value)
  find(:xpath, "//input[@name='#{name}']/ancestor::form").find("input[type='submit']").click()
end

Then /^I set the input in the fieldset with "(.*?)" as meta\-key to "(.*?)"$/ do |meta_key_id, value|
  find("fieldset[data-meta-key='#{meta_key_id}']").find("input,textarea",visible: true).set(value)
end

When /^I submit$/ do
  all("form").last.find("[type='submit']").click
end

When /^I use the "(.*?)" context action$/ do |context_name|  
  find("a",text: "Weitere Aktionen").click
  find("a",text: context_name).click
end

### I s⋯ ###################################################

When /^I scroll all the way down and click on "(.*?)"$/ do |text|
  page.execute_script "window.scrollBy(0,10000)"
  find("a,button",text: text).click
end


### I t⋯ ###################################################
Given /^I take a screenshot$/ do
  case Capybara.current_driver
  when :selenium_chrome
    Rails.logger.warn "can't take screenshot with the chromedriver" 
  else
    Capybara::Screenshot.screenshot_and_save_page
  end
end

When /^I try to leave the page$/ do
  @current_path = page.current_path
  find("a[href='#{root_path}']").click
end


### I w⋯ ###################################################

When /^I wait for the dialog to appear$/ do
  wait_until{all(".modal.ui-shown").size > 0 }
end

When /^I wait for the dialog to disappear$/ do
  wait_until{all(".modal-backdrop").size == 0 }
end

Given /^I wait for the following to be implemented$/ do
  pending
end

When /^I wait until I am on the "(.*?)" page$/ do |path|
  wait_until{ current_path == path }
end

When(/^I wait for the class "(.*?)" to be present$/) do |css_class|
  wait_until{ all(".#{css_class}").size > 0}
end


When /^I visit the "(.*?)" path$/ do |path|
  visit path
end


### T #########################################################

Then /^There is a link with the id "(.*?)"$/ do |id|
  expect(find "a##{id}" ).to be
end

Then /^There is a link with class "(.*?)" in the list with class "(.*?)"$/ do |link_class, list_class|
  expect{ find("ul.#{list_class} a.#{link_class}") }.not_to raise_error
end

Then /^There is no link with class "(.*?)" in the list with class "(.*?)"$/ do |link_class, list_class|
  expect{ find("ul.#{list_class} a.#{link_class}") }.to raise_error
end







