# the common steps are lexically ordered, 
# PLEASE KEEP IT THIS WAY!

Given /^I am signed\-in as "(.*?)"$/ do |login|
  visit "/"
  find("a#database-user-login-tab").click
  find("input[name='login']").set(login)
  find("input[name='password']").set('password')
  find("button[type='submit']").click
  @current_user = User.find_by_login login
end

Then /^I can see the text "(.*?)"$/ do |text|
  expect(page.has_content? text).to be true
end

When /^I click the submit input$/ do
  find("input[type='submit']").click
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

When /^I pry$/ do
  binding.pry 
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
