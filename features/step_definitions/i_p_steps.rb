# -*- encoding : utf-8 -*-

Then /^I put a set A that has media entries in set B that has any context$/ do
  @media_set_a = @current_user.media_sets.detect{|ms| ms.individual_contexts.count == 0 and ms.child_media_resources.media_entries.count > 0}
  @media_set_b = @current_user.media_sets.detect{|ms| ms.individual_contexts.count > 0}
  visit media_set_path(@media_set_a)
  step 'I open the organize dialog'
  find("[name='search_or_create_set']").set @media_set_b.title
  wait_until {all("#parent_resource_#{@media_set_b.id}").size > 0}
  find("#parent_resource_#{@media_set_b.id}").click
  step 'I submit'
  step 'I wait for the dialog to disappear'
end

Then /^I provide a name$/ do
  @name = Faker::Name.last_name
  find("input[name='name']").set @name
end

Then /^I provide a title$/ do
  @title = Faker::Name.name
  find("input[name='title']").set @title
end

Then /^I pry$/ do
  binding.pry 
end
