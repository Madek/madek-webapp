When /^I visit a public media entry with individual contexts$/ do
  media_entry = MediaEntry.accessible_by_user(@current_user).detect {|x| x.title == "Schweizer Panorama"}
  visit resource_path(media_entry)
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
