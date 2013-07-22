Then /^I can see the delete action for media resources where I am responsible for$/ do
  all(".ui-resource[data-id]").each do |resource_el|
    media_resource = MediaResource.find resource_el["data-id"]
    if @current_user.authorized?(:delete, media_resource)
      resource_el.find("[data-delete-action]")
    end
  end
end

Then /^I cannot see the delete action for media resources where I am not responsible for$/ do
  all(".ui-resource[data-id]").each do |resource_el|
    media_resource = MediaResource.find resource_el["data-id"]
    if not @current_user.authorized?(:delete, media_resource)
      resource_el.all("[data-delete-action]").size.should == 0
    end
  end
end

Then /^I cannot see the delete action for this resource$/ do
  all(".ui-body-title-actions [data-delete-action]").size.should == 0
end

Then /^I can see the delete action for this resource$/ do
  find(".ui-body-title-actions .primary-button").click
  find("[data-delete-action]")
end

When(/^I remember the last imported media_entry with media_file and the actual file$/) do
  @media_entry = MediaEntry.reorder("created_at DESC").first
  @media_file = @media_entry.media_file
  @file = @media_file.file_storage_location
end


When(/^I visit the media_entry$/) do
  visit media_entry_path(@media_entry)
end


Then(/^The media_resource does exist$/) do
  expect(MediaEntry.where(id: @media_entry.id).count).to be > 0
end

Then(/^The media_file does exist$/) do
  expect(MediaFile.where(id: @media_file.id).count).to be > 0 
end

Then(/^The actual_file does exist$/) do
  expect(File.exists? @file).to be true
end

Then(/^The media_entry doesn't exist anymore$/) do
  wait_until{MediaEntry.where(id: @media_entry.id).count == 0}
end

Then(/^The media_file doesn't exist anymore$/) do
  expect(MediaFile.where(id: @media_file.id).count).to be == 0
end

Then(/^The actual_file doesn't exist anymore$/) do
  expect(File.exists? @file).to be false
end
