# -*- encoding : utf-8 -*-
Then /^I inspect a media set node more closely$/ do
  @media_resource= @current_user.media_sets.first
  page.execute_script("Test.Visualization.mouse_enter_set('#{@media_resource.id}')")
end

Then /^I inspect a media entry node more closely$/ do
  @media_resource= @current_user.media_entries.first
  page.execute_script("Test.Visualization.mouse_enter_set('#{@media_resource.id}')")
end


