Given /^A resource with no permissions whatsoever$/ do
  @resource = User.find_by_login("petra").media_entries.first
  @resource.update_attributes download: false, edit: false, manage: false, view: false
  @resource.grouppermissions.clear
  @resource.grouppermissions.clear
end

When /^There are "(.*?)" user-permissions added for me to the resources$/ do |permission|
  permissions = \
    @resource.userpermissions.where(user_id: @me).first  \
    || @resource.userpermissions.create(user: @me)
  permissions.update_attributes permission => true
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

When /^I open the edit-permissions dialog$/ do
  find(".primary-button").click
  find("a[data-open-permissions]").click
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
  wait_until{all(".ui-rights-management-others").size == 0}
  sleep 0.100
  expect(permissions.reload.download).not_to eq orig_download_permissions
end
