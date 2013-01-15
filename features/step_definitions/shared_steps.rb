# the common steps are lexically ordered, 
# PLEASE KEEP IT THIS WAY!
#

Then /^I am on the page of the resource$/ do
  expect(current_path).to eq media_entry_path @resource
end

Given /^I am signed\-in as "(.*?)"$/ do |login|
  visit "/"
  find("a#database-user-login-tab").click
  find("input[name='login']").set(login)
  find("input[name='password']").set('password')
  find("button[type='submit']").click
  @me = @current_user = User.find_by_login login
end

Then /^I can see the text "(.*?)"$/ do |text|
  expect(page.has_content? text).to be true
end

When /^I click on the link "(.*?)"$/ do |link_text|
  wait_until(1){ all("a", text: link_text, visible: true).size > 0}
  find("a",text: link_text).click
end 

When /^I click on the link "(.*?)" inside of the dialog$/ do |link_text|
  wait_until(2){ all("#ui-export-dialog.ui-shown a", text: link_text, visible: true).size > 0}
  find("a",text: link_text).click
end

When /^I click on the button "(.*?)"$/ do |button_text|
  find("button",text: button_text).click
end

When /^I click the submit input$/ do
  find("input[type='submit']").click
end

When /^I click on the submit button$/ do
  find("button[type='submit']").click
end

Given /^I close the modal dialog\.$/ do
  find(".modal a[data-dismiss='modal']").click
  wait_until{all(".modal-backdrop").size == 0}
end

When /^(?:|I )fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    step %{I fill in "#{name}" with "#{value}"}
  end
end

When /^I follow the link with the text "(.*?)"$/ do |text|
  find("a",text: text).click
end

When /^I go to the home page$/ do
  visit "/"
end

Given /^I logout\.$/ do
  find(".app-header .ui-header-user a").click
  find("a[href='/logout']").click
end

When /^I pry$/ do
  binding.pry 
end

Then /^I see an error alert$/ do
  expect{ find(".ui-alert.error",visible: true) }.not_to raise_error
end

Then /^I see a confirmation alert$/ do
  expect{ find(".ui-alert.confirmation",visible: true) }.not_to raise_error
end

When /^I set the input with the name "(.*?)" to "(.*?)"$/ do |name, value|
  find("input[name='#{name}']").set(value)
end

When /^I use the "(.*?)" context action$/ do |context_name|  
  find("a",text: "Weitere Aktionen").click
  find("a",text: context_name).click
end

Given /^I wait for the following to be implemented$/ do
  pending
end

Then /^There is a link with class "(.*?)" in the list with class "(.*?)"$/ do |link_class, list_class|
  expect{ find("ul.#{list_class} a.#{link_class}") }.not_to raise_error
end

Then /^There is no link with class "(.*?)" in the list with class "(.*?)"$/ do |link_class, list_class|
  expect{ find("ul.#{list_class} a.#{link_class}") }.to raise_error
end



