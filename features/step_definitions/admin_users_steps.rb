When /^I follow the first link to create a new user$/ do
  all("a",text:"Create User").first.click
end

When /^I open the admin\/users interface$/ do
  visit "admin/users"
end

When /^I delete a user$/ do
  all("a",text: "Delete").first.click
end

When /^I edit a user$/ do
  all("a",text: "Edit").first.click
end


When(/^I set the input with the name "(.*?)" to the id of a newly created person$/) do |name|
  @person = FactoryGirl.create :person
  find("input[name='#{name}']").set(@person.id)
end
