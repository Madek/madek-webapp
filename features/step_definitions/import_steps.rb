When /^I attach the file "(.*?)"$/ do |file_name|
  attach_file find("input[type='file']")[:id], Rails.root.join("features","data","images",file_name)
end

Given /^I am going to import three images$/ do
  @previouse_media_entries = MediaEntry.all
  @previouse_media_sets = MediaSet.all
end

Then /^there are three new media_entries$/ do
  @new_media_entries = MediaEntry.all - @previouse_media_entries
  expect(@new_media_entries.size).to eq 3
end

Then /^there is a new set "(.*?)" that includes those new media\-entries$/ do |title|
  expect(@new_set = MediaSet.find_by_title(title)).to be
  expect((@new_set.child_media_resources and @new_media_entries).to_a).to eq @new_media_entries
end


Then /^there is a entry with the title "(.*?)" in the new media_entries$/ do |title|
  expect(@new_media_entries.map(&:title)).to include title
end

Then /^Petra has "(.*?)" user\-permission on the new media_entry with the tile "(.*?)"$/ do |permission, title|
  me = @new_media_entries.select{|me| me.title == title}.first
  userpermission = me.userpermissions.joins(:user).where("users.login = 'petra'").first
  expect(userpermission.send permission).to be_true
end
