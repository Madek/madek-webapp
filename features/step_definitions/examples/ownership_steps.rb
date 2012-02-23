When /^I see a list of resources$/ do
  visit root_path
end

Then /^I can see if a resource is only visible for me$/ do
  find(".item_box .icon_status_perm_private")
end

Then /^I can see if a resource is visible for multiple other users$/ do
  find(".item_box .icon_status_perm_shared")
end

Then /^I can see if a resource is visible for the public$/ do
  find(".item_box .icon_status_perm_public")
end