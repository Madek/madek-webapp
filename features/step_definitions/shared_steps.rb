# The common steps are lexically ordered. 
# PLEASE KEEP IT THIS WAY!
#

### I am #########################################

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
  wait_until {  all("button", text: button_text).size > 0 }
  find("button",text: button_text).click
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
  page.driver.browser.switch_to.alert.accept
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
  page.driver.browser.switch_to.alert.accept
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
end

Then /^I set the input in the fieldset with "(.*?)" as meta\-key to "(.*?)"$/ do |meta_key_name, value|
  find("fieldset[data-meta-key='#{meta_key_name}'] input",visible: true).set(value)
end

When /^I use the "(.*?)" context action$/ do |context_name|  
  find("a",text: "Weitere Aktionen").click
  find("a",text: context_name).click
end

### I s⋯ ###################################################

When /^I try to leave the page$/ do
  @current_path = page.current_path
  find("a[href='#{root_path}']").click
end

### I w⋯ ###################################################

When /^I wait for the dialog to appear$/ do
  wait_until{all(".modal.ui-shown").size > 0 }
end

When /^I wait for the dialog to disappear$/ do
  wait_until(5){all(".modal-backdrop").size == 0 }
end

Given /^I wait for the following to be implemented$/ do
  pending
end

When /^I wait until I am on the "(.*?)" page$/ do |path|
  wait_until(10){ current_path == path }
end

### T #########################################################

Then /^There is a link with class "(.*?)" in the list with class "(.*?)"$/ do |link_class, list_class|
  expect{ find("ul.#{list_class} a.#{link_class}") }.not_to raise_error
end

Then /^There is no link with class "(.*?)" in the list with class "(.*?)"$/ do |link_class, list_class|
  expect{ find("ul.#{list_class} a.#{link_class}") }.to raise_error
end




