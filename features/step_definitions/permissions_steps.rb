# -*- encoding : utf-8 -*-

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

Given /^A set, not owned by normin, and with no permissions whatsoever$/ do
  @set = User.find_by_login("petra").media_sets.first
  @set.update_attributes download: false, edit: false, manage: false, view: false
  @set.userpermissions.clear
  @set.grouppermissions.clear
end


Given /^A resource owned by me$/ do
  @resource = @me.media_resources.first
end

Given /^I add the resource to the given set$/ do
  wait_until{all(".ui-modal input.ui-search-input").size > 0}
  find(".ui-modal input.ui-search-input").set(@set.title)
  wait_until{all("ol.ui-set-list li").size > 0 }
  expect(all("ol.ui-set-list li").size).to eq 1
  find("ol.ui-set-list li input[type='checkbox']#parent_resource_#{@set.id}").click
  find("button.primary-button").click
  wait_until{all(".modal-backdrop").size == 0}
end

When /^I am on the edit page of the resource$/ do
  expect(current_path).to eq edit_media_resource_path @resource
end

Then /^I am redirected to the main page$/ do
  expect(current_path).to eq "/my"
end

Then /^I am the responsible person for that resource$/ do
  expect(find(".ui-rights-management-current-user td.ui-rights-owner input")).to be_checked
end

Then /^I am not the responsible person for that resource$/ do
  expect(find(".ui-rights-management-current-user td.ui-rights-owner input")).not_to be_checked
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

When /^There are "(.*?)" user-permissions added for me to the resource$/ do |permission|
  permissions = \
    @resource.userpermissions.where(user_id: @me).first  \
    || @resource.userpermissions.create(user: @me)
  permissions.update_attributes permission => true
end


Given /^There are "(.*?)" user\-permissions added for me to the set$/ do |permission|
  permissions = \
    @set.userpermissions.where(user_id: @me).first  \
    || @set.userpermissions.create(user: @me)
  permissions.update_attributes permission => true
end


Given /^The set has no children$/ do
  @set.child_media_resources.clear
end

Then /^the resource is in the children of the given set$/ do
  expect(@set.child_media_resources.reload).to include @resource
end



