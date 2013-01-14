Given /^A media_entry with file, not owned by normin, and with no permissions whatsoever$/ do
  @petra = User.find_by_login("petra")
  @resource = FactoryGirl.create :media_entry, user: @petra
  @resource.update_attributes download: false, edit: false, manage: false, view: false
  @resource.userpermissions.clear
  @resource.grouppermissions.clear
end

Given /^A resource, not owned by normin, and with no permissions whatsoever$/ do
  @resource = User.find_by_login("petra").media_entries.first
  @resource.update_attributes download: false, edit: false, manage: false, view: false
  @resource.userpermissions.clear
  @resource.grouppermissions.clear
end

When /^I am on the edit page of the resource$/ do
  expect(current_path).to eq edit_media_resource_path @resource
end

Then /^I am redirected to the main page$/ do
  expect(current_path).to eq "/my"
end

Then /^I can not edit the permissions/ do
  permissions = @resource.userpermissions.where(user_id: @me).first
  orig_download_permissions = permissions.download
  find("tr[data-name='#{@me.name}']").find("input[name=download]").click
  expect{find("button.primary-button[type=submit]")}.to raise_error
end

Then /^I can edit the permissions/ do
  permissions = @resource.userpermissions.where(user_id: @me).first
  orig_download_permissions = permissions.download
  find("tr[data-name='#{@me.name}']").find("input[name=download]").click
  find("button.primary-button[type=submit]").click
  wait_until{all(".modal-backdrop").size == 0}
  expect(permissions.reload.download).not_to eq orig_download_permissions
end

Then /^I see page for the resource$/ do
  expect(find(".app-body-title h1").text).to eq @resource.title
end

When /^I open the edit-permissions dialog$/ do
  find(".primary-button").click
  find("a[data-open-permissions]").click
end

When /^I visit the path of the resource$/ do
  visit media_resource_path @resource
end

When /^There are "(.*?)" user-permissions added for me to the resources$/ do |permission|
  permissions = \
    @resource.userpermissions.where(user_id: @me).first  \
    || @resource.userpermissions.create(user: @me)
  permissions.update_attributes permission => true
end


When /^I click on the "(.*?)" button$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^There is a "(.*?)" link in the "(.*?)" list$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end
