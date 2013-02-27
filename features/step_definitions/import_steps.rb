When /^I attach the file "(.*?)"$/ do |file_name|
  attach_file find("input[type='file']")[:id], Rails.root.join("features","data",file_name)
end

Given /^I am going to import images$/ do
  @previous_media_entries = MediaEntry.all
  @previous_media_sets = MediaSet.all
  @previous_zencoder_jobs = ZencoderJob.all
end

Then /^there are "(.*?)" new media_entries$/ do |num|
  @new_media_entries = MediaEntry.all - @previous_media_entries
  expect(@new_media_entries.size).to eq num.to_i
end

Then /^there are "(.*?)" new zencoder_jobs/ do |num|
  @new_zencoder_jobs = ZencoderJob.all - @previous_zencoder_jobs
  expect(@new_zencoder_jobs.size).to eq num.to_i
end

Then /^there is a new set "(.*?)" that includes those new media\-entries$/ do |title|
  @new_media_entries = MediaEntry.all - @previous_media_entries
  expect(@new_set = MediaSet.find_by_title(title)).to be
  expect((@new_set.child_media_resources and @new_media_entries).to_a).to eq @new_media_entries
end

Then /^there is a entry with the title "(.*?)" in the new media_entries$/ do |title|
  @new_media_entries = MediaEntry.all - @previous_media_entries
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

Then /^two files with missing metadata are marked$/ do
  wait_until{all("ul.ui-resources li.ui-invalid").size > 1}
  expect(all("ul.ui-resources li.ui-invalid").size).to eq 2
end

When /^I choose to list only files with missing metadata$/ do
  find("input#display-only-invalid-resources").click
end

Then /^Only the files with missing metadata are listed$/ do
  expect(all("ul.ui-resources li",visible: true).size).to eq 2
end

Then /^there is "(.*?)" in my imports$/ do |file_name|
  expect(find("#mei_filelist li", text: file_name)).to be
end

Given /^There is no media\-entry with a filename matching "(.*?)"$/ do |fn_match|
  MediaEntry.all.select{|me| me.media_file.filename =~ /berlin/}.each(&:destroy)
end

Given /^There is no incomplete media\-entry with a filename matching "(.*?)"$/ do |fn_match|
  MediaEntryIncomplete.all.select{|me| me.media_file.filename =~ /berlin/}.each(&:destroy)
end


When /^I delete the import "(.*?)"$/ do |text|
  find("ul#mei_filelist li",text: text).find("a.delete_mei").click
end

Then /^There is exactly one media\-entry with a filename matching "(.*?)"$/ do |name|
  expect(MediaEntry.all.select{|me| me.media_file.filename =~ /#{name}/}.size).to eq 1
end

Then /^There is no media\-entry incomplete with a filename matching "(.*?)"$/ do |name|
  expect(MediaEntryIncomplete.all.select{|me| me.media_file.filename =~ /#{name}/}.size).to eq 0
end

When /^I visit the page of the last added media_entry$/ do
  visit media_entry_path MediaEntry.order(:created_at).last
end

Then /^The most recent zencoder_job has the state "(.*?)"$/ do |state|
  expect(ZencoderJob.reorder("created_at DESC").first.state ).to eq state
end
