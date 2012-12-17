# coding: utf-8

Then /^I can open the context actions drop down and see the following actions in the following order:$/ do |table|
  table.hashes.each {|hash| find_context_action hash[:action]}
end

When /^I see some search results$/ do
  visit media_resources_path(:search => "")
end

When /^I open a filter set that I can edit$/ do
  filter_set =  FilterSet.accessible_by_user(@current_user, :edit).first
  visit media_resource_path filter_set
end

When /^I use the "(.*?)" context action$/ do |name|
  find_context_action(name).find("a").click
end