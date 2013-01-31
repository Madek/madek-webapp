When /^I attach the file "(.*?)"$/ do |file_name|
  attach_file find("input[type='file']")[:id], Rails.root.join("features","data","images",file_name)
end

Given /^I am going to import images$/ do
  @previouse_media_entries = MediaEntry.all
  @previouse_media_sets = MediaSet.all
end

Then /^there are "(.*?)" new media_entries$/ do |num|
  @new_media_entries = MediaEntry.all - @previouse_media_entries
  expect(@new_media_entries.size).to eq num.to_i
end

Then /^there is a new set "(.*?)" that includes those new media\-entries$/ do |title|
  @new_media_entries = MediaEntry.all - @previouse_media_entries
  expect(@new_set = MediaSet.find_by_title(title)).to be
  expect((@new_set.child_media_resources and @new_media_entries).to_a).to eq @new_media_entries
end


Then /^there is a entry with the title "(.*?)" in the new media_entries$/ do |title|
  @new_media_entries = MediaEntry.all - @previouse_media_entries
  expect(@new_media_entries.map(&:title)).to include title
end

Then /^Petra has "(.*?)" user\-permission on the new media_entry with the tile "(.*?)"$/ do |permission, title|
  me = @new_media_entries.select{|me| me.title == title}.first
  userpermission = me.userpermissions.joins(:user).where("users.login = 'petra'").first
  expect(userpermission.send permission).to be_true
end

Then /^I can see that the fieldset with "(.*?)" as meta\-key is required$/ do |meta_key_name|
  expect(find("fieldset.error[data-meta-key='#{meta_key_name}']")).to be
end
