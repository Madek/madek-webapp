Given /^A resource with no permissions whatsoever$/ do
  @resource = User.find_by_login("petra").media_entries.first
  @resource.update_attributes download: false, edit: false, manage: false, view: false
  @resource.grouppermissions.clear
  @resource.grouppermissions.clear
end

When /^There are view permissions added for me to the resources$/ do
  @resource.userpermissions.create user: @me, view: true
end

When /^I visit the path of the resource$/ do
  visit media_resource_path @resource
end

Then /^I am redirected to the main page$/ do
  expect(current_path).to eq "/my"
end

Then /^I see page for the resource$/ do
  expect(find(".app-body-title h1").text).to eq @resource.title
end
