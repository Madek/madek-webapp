# -*- encoding : utf-8 -*-
 
Then /^I remove "(.*?)" from the user\-permissions$/ do |user_name|
  find("table.ui-rights-group td",text: user_name).find("a.ui-rights-remove").click
end

Then /^I remove "(.*?)" from the group\-permissions$/ do |group_name|
  find("table.ui-rights-group td",text: group_name).find("a.ui-rights-remove").click
end

Then /^I remove all members of a specific group except myself$/ do
  all_users_expect_myself = @group.users.where(User.arel_table[:id].not_eq(@current_user.id))
  all_users_expect_myself.each do |user|
    find("#user-list tr", :text => user.to_s).find(".button[data-remove-user]").click
    wait_until {all("#user-list tr", :text => user.to_s).size == 0}
  end
  wait_until(6){all("#user-list tr").size == 1}
  step 'I click the primary action of this dialog'
end

Then /^I remember the count for the filter "(.*?)"$/ do |filter|
  @count= find("li.resources_filter",text: filter).find(".resources_count").text.to_i
end

Then /^I remember a media_entry that doesn't belong to me, has no public, nor other permissions$/  do
  @media_entry = @media_resource = @resource = MediaEntry.where.not(user_id: @me.id).first
  @media_entry.update_attributes! view: false, download: false, manage: false, edit: false
  @media_entry.userpermissions.destroy_all
  @media_entry.grouppermissions.destroy_all
end

When(/^I remember the id of the first group-row$/) do
  @id = all("tr.group").first[:id]
end

Then /^I remember the number of ZencoderJobs$/ do
  @zencoder_jobs_number = all("table.zencoder-jobs tbody tr").size rescue 0
end

Then /^I remember the number of resources$/ do
  @resources_counter = find("#resources_counter").text.to_i
end

Then /^I remember the last imported media_entry with media_file and the actual file$/ do
  @media_entry = MediaEntry.reorder("created_at DESC").first
  @media_file = @media_entry.media_file
  @file = @media_file.file_storage_location
end

Given(/^I remember this media_resource$/) do
  uuid = current_path.match(/\/([\w-]+)$/)[1] 
  @resource = @media_resource= MediaResource.find uuid
end

Then /^I remove a set A from a set B from which set A is inheriting a context$/ do
  step 'I put a set A that has media entries in set B that has any context'
  @individual_context = @media_set_b.individual_contexts.first
  visit media_set_path(@media_set_a)
  step 'I open the organize dialog'
  wait_until {all("#parent_resource_#{@media_set_b.id}").size > 0}
  find("#parent_resource_#{@media_set_b.id}").click
  step 'I submit'
  step 'I wait for the dialog to disappear'
end

Then /^I remove all uploaded files$/ do
 all("ul#mei_filelist > li a.delete_mei").each do |link|
    link.click()
    page.driver.browser.switch_to.alert.accept 
 end
end

Then /^I remove all permissions from my first media_entry$/ do
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @my_first_media_entry.userpermissions.clear
  @my_first_media_entry.grouppermissions.clear
end

Given(/^I remove all permissions from "(.*?)"\\'s first media_entry$/) do |login|
  @media_entry = User.find_by_login(login).media_entries.reorder("created_at ASC").first
  @media_entry.userpermissions.clear
  @media_entry.grouppermissions.clear
end
