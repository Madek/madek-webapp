# -*- encoding : utf-8 -*-
 
Then /^there is "(.*?)" in my imports$/ do |file_name|
  expect(find("#mei_filelist li", text: file_name)).to be
end

Then (/^There is an element with the data\-context\-name "(.*?)" in the ui\-resource\-body$/) do |name|
  expect(find(".ui-resource-body *[data-context-name='#{name}']")).to be
end

Then(/^There is not an element with the data\-context\-name "(.*?)" in the ui\-resource\-body$/) do |name|
  expect(all(".ui-resource-body *[data-context-name='#{name}']").size).to be== 0
end

Then /^There is a link to content assigned to me$/ do
  expect(find "#user_entrusted_resources_block a[href*='/my/entrusted_media_resources']").to be
end

Then /^There is a link to my favorites$/ do
  expect(find "#user_favorite_resources_block a[href*='/my/favorites']").to be
end

Then /^There is a link to my keywords$/ do
  expect(find "#user_keywords_block a[href*='/my/keywords']").to be
end

Then /^There is a link to my groups$/ do
  expect(find "#my_groups_block a[href*='/my/groups']").to be
end

Then /^There is a link to my resources$/ do
  expect(find "#latest_user_resources_block a[href*='/my/media_resources']").to be
end

Then /^There is a link to the "(.*?)" path$/ do |path|
  expect("a[href='#{path}']").to be
end

Then /^There is a link with the id "(.*?)"$/ do |id|
  expect(find "a##{id}" ).to be
end

Then /^There is a link with class "(.*?)" in the list with class "(.*?)"$/ do |link_class, list_class|
  expect{ find("ul.#{list_class} a.#{link_class}") }.not_to raise_error
end

Then (/^There is a movie with previews and public viewing\-permission$/) do
  System.execute_cmd! "tar xf #{Rails.root.join "features/data/media_files_with_movie.tar.gz"} -C #{Rails.root.join  "db/media_files/", Rails.env}"
  @movie = MediaFile.find_by(guid: "66b1ef50186645438c047179f54ec6e6").media_entry
end

Then /^There is no link with class "(.*?)" in the list with class "(.*?)"$/ do |link_class, list_class|
  expect{ find("ul.#{list_class} a.#{link_class}") }.to raise_error
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

Then /^There is exactly one media\-entry with a filename matching "(.*?)"$/ do |name|
  expect(MediaEntry.all.select{|me| me.media_file.filename =~ /#{name}/}.size).to eq 1
end

Then /^There is no incomplete media\-entry with a filename matching "(.*?)"$/ do |fn_match|
  MediaEntryIncomplete.all.select{|me| me.media_file.filename =~ /berlin/}.each(&:destroy)
end

Then /^There is no media\-entry with a filename matching "(.*?)"$/ do |fn_match|
  MediaEntry.all.select{|me| me.media_file.filename =~ /berlin/}.each(&:destroy)
end

Then /^There is no media\-entry incomplete with a filename matching "(.*?)"$/ do |name|
  expect(MediaEntryIncomplete.all.select{|me| me.media_file.filename =~ /#{name}/}.size).to eq 0
end

Then /^There is "(.*?)" sorting option selected$/ do |option|
  within "select[name='sort_by']" do
    expect(find("option[value='resources_amount']")[:selected]).to eq("selected")
  end
end

Then /^There is "(.*?)" group type option selected$/ do |option|
  within "select[name='type']" do
    expect(find("option[value='#{option}']")[:selected]).to eq("selected")
  end
end
