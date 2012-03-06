# coding: UTF-8

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

Then /^I see a list of content owned by me$/ do
  find("#content_body .page_title_left", :text => "Meine Inhalte")
end

Then /^I see a list of content that can be managed by me$/ do
  find("#content_body2 .page_title_left", :text => "Mir anvertraute Inhalte")
end

Then /^I see a list of other people's content that is visible to me$/ do
  find("#content_body2 .page_title_left", :text => "Öffentliche Inhalte")
end


