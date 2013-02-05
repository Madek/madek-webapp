# -*- encoding : utf-8 -*-

Given /^I remove all permissions from my first media_entry$/ do
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @my_first_media_entry.userpermissions.clear
  @my_first_media_entry.grouppermissions.clear
end

Given /^I visit the path of my first media entry$/ do
  visit media_resource_path @me.media_entries.reorder("created_at ASC").first
end

Then /^User "(.*?)" has "(.*?)" user\-permissions for my first media_entry$/ do |login, permission|
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @user = User.where(login: login).first
  up = Userpermission.where(media_resource_id: @my_first_media_entry.id).where(user_id: @user.id).first
  expect(up.send(permission)).to be_true
end

Then /^User "(.*?)" has not "(.*?)" user\-permissions for my first media_entry$/ do |login, permission|
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @user = User.where(login: login).first
  up = Userpermission.where(media_resource_id: @my_first_media_entry.id).where(user_id: @user.id).first
  expect(up.send(permission)).to be_false
end

Then /^Group "(.*?)" has "(.*?)" group\-permissions for my first media_entry$/ do |name, permission|
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @group = Group.where(name: name).first
  up = Grouppermission.where(media_resource_id: @my_first_media_entry.id).where(group_id: @group.id).first
  expect(up.send(permission)).to be_true
end

Then /^Group "(.*?)" has not "(.*?)" group\-permissions for my first media_entry$/ do |name, permission|
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @group = Group.where(name: name).first
  up = Grouppermission.where(media_resource_id: @my_first_media_entry.id).where(group_id: @group.id).first
  expect(up.send(permission)).to be_false
end

When /^I remove "(.*?)" from the user\-permissions$/ do |user_name|
  find("table.ui-rights-group td",text: user_name).find("a.ui-rights-remove").click
end

Then /^"(.*?)" has no user\-permission for my first media_entry$/ do |login|
  expect(
    @me.media_entries.reorder("created_at ASC").first.userpermissions.joins(:user).where("users.login = ?",login).count 
  ).to eq 0
end

When /^I remove "(.*?)" from the group\-permissions$/ do |group_name|
  find("table.ui-rights-group td",text: group_name).find("a.ui-rights-remove").click
end

Then /^"(.*?)" has no group\-permission for my first media_entry$/ do |group_name|
  expect(
    @me.media_entries.reorder("created_at ASC").first.grouppermissions.joins(:group).where("groups.name= ?",group_name).count 
  ).to eq 0
end

Given /^A media_entry with file, not owned by normin, and with no permissions whatsoever$/ do
  @petra = User.find_by_login("petra")
  @resource = FactoryGirl.create :media_entry, user: @petra
  @resource.update_attributes download: false, edit: false, manage: false, view: false
  @resource.userpermissions.clear
  @resource.grouppermissions.clear
end

Given /^A resource owned by me with no other permissions$/ do
  @resource = @me.media_resources.first
  @resource.userpermissions.clear
  @resource.grouppermissions.clear
  @resource.update_attributes view: false, edit: false, manage: false, download: false
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

Given /^A resource owned by me and defined userpermissions for "(.*?)"$/ do |login|
  @user_with_userpermissions = User.find_by_login login
  @resource = MediaResource.where(user_id: @me.id).joins(:userpermissions)\
    .where("userpermissions.user_id = ?", @user_with_userpermissions.id).first
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

Given /^I add "(.*?)" to grant user permissions$/ do |name|
  wait_until{all(".ui-modal").size > 0}
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

Then /^I can choose from a set of labeled permissions presets instead of grant permissions explicitly$/ do
  step 'I wait for the dialog to appear'
  expect(all("tr[data-name='#{@user_with_userpermissions.name}'] select.ui-rights-role-select option").size).to be > 0
end

Then /^I can edit the permissions/ do
  permissions = @resource.userpermissions.where(user_id: @me).first
  orig_download_permissions = permissions.download
  find("tr[data-name='#{@me.name}']").find("input[name=download]").click
  find("button.primary-button[type=submit]").click
  wait_until{all(".modal-backdrop").size == 0}
  expect(permissions.reload.download).not_to eq orig_download_permissions
end

Then /^I can not edit the permissions/ do
  permissions = @resource.userpermissions.where(user_id: @me).first
  orig_download_permissions = permissions.download
  find("tr[data-name='#{@me.name}']").find("input[name=download]").click
  expect{find("button.primary-button[type=submit]")}.to raise_error
end

Then /^I can select "(.*?)" to grant group permissions$/ do |group|
  #wait_until{ all("#addGroup a", text: "Gruppe hinz").size > 0 }
  find("#addGroup a",text: "Gruppe hinz").click
  find("#addGroup input[type='text']").set group[0..10]
  find("ul.ui-autocomplete li a",text: group).click
end


When /^I click on the "(.*?)" permission for "(.*?)"$/ do |permission, user|
  find("tr[data-name='#{user}'] input[name='#{permission}']").click
end

Given /^I have set up some departments with ldap references$/ do
  MetaDepartment.create([
   {:ldap_id => "4396.studierende", :ldap_name => "DKV_FAE_BAE.studierende", :name => "Bachelor Vermittlung von Kunst und Design"},
   {:ldap_id => "56663.dozierende", :ldap_name => "DDE_FDE_VID.dozierende", :name => "Vertiefung Industrial Design"} 
  ]) 
end


Then /^I see page for the resource$/ do
  expect(find(".app-body-title h1").text).to eq @resource.title
end

Then /^I see the following permissions:$/ do |table|
  table.rows.each do |row|
    user= User.find_by_login row[0]
    expect(find("tr[data-name='#{user.name}'] input[name='#{row[1]}']")).to be_checked
  end
end

When /^I open the edit-permissions dialog$/ do
  find(".primary-button").click
  find("a[data-open-permissions]").click
  step 'I wait for the dialog to appear'
end

When /^I visit the path of the resource$/ do
  visit media_resource_path @resource
end

When /^I visit the edit path of the resource$/ do
  visit edit_media_resource_path @resource
end

Given /^I visit the permissions dialog of the resource$/ do
  visit media_resource_path @resource
  find("a",text: "Weitere Aktionen").click
  find("a",text: "Zugriffsberechtigungen").click
  step 'I wait for the dialog to appear'
end


When /^There are "(.*?)" user-permissions added for me to the resource$/ do |permission|
  permissions = \
    @resource.userpermissions.where(user_id: @me).first  \
    || @resource.userpermissions.create(user: @me)
  permissions.update_attributes permission => true
end


When /^There are "(.*?)" group\-permissions added for me to the resource$/ do |permission|  
  group = Group.joins(:users).where("groups_users.user_id = ?", @me.id).first || (FactoryGirl.create :group)
  group.users << @me unless group.users.include? @me
  grouppermissions = Grouppermission.where(media_resource_id: @resource.id).where(group_id: group.id).first || (Grouppermission.create media_resource_id: @resource.id, group_id: group.id)
  grouppermissions.update_attributes permission => true
end

Given /^There are "(.*?)" user\-permissions added for me to the set$/ do |permission|
  permissions = \
    @set.userpermissions.where(user_id: @me).first  \
    || @set.userpermissions.create(user: @me)
  permissions.update_attributes permission => true
end

Then /^the "(.*?)" permission for "(.*?)" is checked$/ do |permission, user|
  expect(find("tr[data-name='#{user}'] input[name='#{permission}']")).to be_checked
end

Given /^The set has no children$/ do
  @set.child_media_resources.clear
end

Then /^the resource is in the children of the given set$/ do
  expect(@set.child_media_resources.reload).to include @resource
end

Given /^The resource has the following user-permissions:$/ do |table|
  table.rows.each do |row|
    @user = User.find_by_login row[0]
    permissions = \
      @resource.userpermissions.where(user_id: @user.id).first  \
      || @resource.userpermissions.create(user: @user)
    permissions.update_attributes row[1] => row[2]
  end
end



