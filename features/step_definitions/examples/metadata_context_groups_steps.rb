When /^I visit a media entry with individual contexts$/ do
  media_entry = MediaEntry.accessible_by_user(@current_user).detect {|x| x.title == "Schweizer Panorama"}
  visit media_resource_path(media_entry)
end

Then /^I see the context group "([^"]*)"$/ do |name|
  step 'I should see "%s"' % name  
end

Then /^I see the context "([^"]*)"$/ do |name|
  step 'I should see "%s"' % name  
end

Then /^I do not see the context "([^"]*)"$/ do |name|
  step 'I should not see "%s"' % name  
end

Then /^the metadata context groups are in the following order:$/ do |table|
  names = table.hashes.map do |row| 
    row["name"]
  end
  all(".meta_context_group > h5").map(&:text).should == names
end

When /^I visit a media entry with the following individual contexts:$/ do |table|
  media_sets = table.hashes.flat_map {|r| MetaContext.find_by_name(r["name"]).media_sets.accessible_by_user(@current_user) }
  
  media_entry = MediaEntry.accessible_by_user(@current_user).detect do |me|
    media_sets.all? {|ms| me.media_sets.include? ms }
  end

  media_entry.should_not be_nil
  table.hashes.each do |row|
    media_entry.individual_contexts.map(&:to_s).include?(row["name"]).should be_true
  end

  visit media_resource_path(media_entry)
end

Then /^the metadata contexts inside of "([^"]*)" are in the following order:$/ do |arg1, table|
  expected = table.hashes.map do |row| 
    row["name"]
  end

  got = find(".meta_context_group > h5", :text => arg1).find(:xpath, "./..").all(".meta_group_name").map(&:text)
  got.keep_if {|x| expected.include? x }
  got.should == expected
end

When /^I visit a media entry without GPS meta data$/ do
  media_entry = MediaEntry.accessible_by_user(@current_user).detect {|x| x.title == "Schweizer Panorama"}
  visit media_resource_path(media_entry)
end

Then /^I do not see the context group "([^"]*)"$/ do |arg1|
  step 'I should not see "%s"' % arg1
  all(".meta_context_group > h5", :text => arg1).should be_empty
end

When /^I visit a media entry with GPS meta data$/ do
  media_entry = MediaEntry.accessible_by_user(@current_user).detect {|x| x.title == "Chinese Temple"}
  visit media_resource_path(media_entry)
end

When /^I expande the context group "([^"]*)"$/ do |arg1|
  find(".meta_context_group > h5", :text => arg1).click
end

Then /^I see the the google map$/ do
  find(".meta_group #map_canvas")
end
