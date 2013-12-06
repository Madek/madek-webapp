# -*- encoding : utf-8 -*-

Then /^I edit a user$/ do
  all("a",text: "Edit").first.click
end

Then /^I edit the contexts of a set that has contexts$/ do
  @media_set = @current_user.media_sets.detect{|ms| ms.individual_contexts.count > 0}
  @individual_contexts = @media_set.individual_contexts
  visit inheritable_contexts_media_set_path @media_set
end

Then /^I edit the filter set settings$/ do
  find("a#resource-action-button").click
  find("a#edit-filter-set").click
end

Then /^I edit one group$/ do
  @group = @current_user.groups.first
  find(".ui-workgroups tr[data-id='#{@group.id}'] .button.edit-workgroup").click
  step 'I wait for the dialog to appear'
end

