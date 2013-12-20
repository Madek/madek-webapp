# -*- encoding : utf-8 -*-
Then /^I visit the media_entry$/ do
  visit media_entry_path(@media_entry)
end

Then /^I visit "(.*?)"$/ do |path|
  visit path
end

Then /^I visit the "(.*?)" path$/ do |path|
  visit path
end

When(/^I visit my first media_set$/) do
  visit media_set_path(@me.media_sets.reorder(:created_at).first)
end

Then /^I visit the page of the last added media_entry$/ do
  visit media_entry_path MediaEntry.order(:created_at).last
end

Then (/^I visit the page of that movie$/) do
  visit media_resource_path(@movie)
end

Then /^I visit the path of a randomly chosen media_entry with public view and download permission$/ do
  visit "/media_entry/" + MediaEntry.where(download: true,view: true).pluck(:id).sample.to_s
end

Then /^I visit the path of the resource$/ do
  visit media_resource_path @resource
end

Then /^I visit the path of my first media entry$/ do
  visit media_resource_path @me.media_entries.reorder("created_at ASC").first
end

Given(/^I visit the path of "(.*?)"\\'s first media entry$/) do |login|
  visit media_resource_path User.find_by_login(login.downcase).media_entries.reorder("created_at ASC").first
end

Then /^I visit the edit path of the resource$/ do
  visit edit_media_resource_path @resource
end

Then /^I visit the permissions dialog of the resource$/ do
  visit media_resource_path @resource
  find("a",text: "Weitere Aktionen").click
  find("a",text: "Berechtigungen").click
  step 'I wait for the dialog to appear'
end

Then /^I visit the visualization of "(.*?)"$/ do |arg1|
  visit "/visualization/#{arg1}"
end

Then /^I visualize the filter Suchergebnisse für "(.*?)"$/ do |search|
  visit  "/visualization/filtered_resources?not_by_user_id=2&public=true&search=#{search}"
end

Then /^I visualize the descendants of a Set$/ do
  @set = @me.media_sets.where(%[ EXISTS (SELECT true FROM media_resource_arcs WHERE child_id = media_resources.id) ]) \
    .where(%[ EXISTS (SELECT true FROM media_resource_arcs WHERE parent_id= media_resources.id) ]).first
  visit "/visualization/descendants_of/#{@set.id}"
end

Then /^I visualize the component of a Entry$/ do
  @entry = @me.media_resources \
    .where(%[ EXISTS (SELECT true FROM media_resource_arcs WHERE child_id = media_resources.id) ]) \
    .first
  visit "/visualization/component_with/#{@entry.id}"
end


