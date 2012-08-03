When /^I see the detail view of a set that I can edit$/ do
  visit media_resource_path MediaResource.media_sets.accessible_by_user(@current_user, :edit).first
end

Then /^I can open the set cover dialog$/ do
  step 'I hover the context actions menu'
  find(".action_menu .action_menu_list a", :text => "Titelbild").click
end

Then /^I see a list of media resources which are inside that set$/ do
  binding.pry
end

When /^I choose one of that media resources$/ do
  binding.pry
end

Then /^that media resource is displayed as cover of that set$/ do
  binding.pry
end