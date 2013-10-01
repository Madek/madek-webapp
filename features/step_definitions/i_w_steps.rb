# -*- encoding : utf-8 -*-
#
Then /^I wait for multi\-select\-tag with the text "(.*?)"$/ do |text|
  wait_until{all("li.multi-select-tag",text: text).size > 0}
end

Then /^I wait for the clipboard to be fully open$/  do
  find(".ui-clipboard.ui-open")
end

Then /^I wait for the dialog to appear$/ do
  wait_until{all(".modal.ui-shown").size > 0 }
end

Then /^I wait for the dialog to disappear$/ do
  wait_until{all(".modal-backdrop").size == 0 }
end

Then /^I wait for the number of resources to change$/ do
  wait_until(3){ 
    if all("#resources_counter").size > 0
      find("#resources_counter").text.to_i != @resources_counter 
    end
  }
end

Then /^I wait and reload while the video is converting$/ do
 while all('.ui-alert', text: /Konvertierung zu .* abgeschlossen/).size > 0 
   sleep 1 
   visit current_path
 end
end

Then (/^I wait for the class "(.*?)" to be present$/) do |css_class|
  wait_until{ all(".#{css_class}").size > 0}
end

Then /^I wait until I am on the "(.*?)" page$/ do |path|
  wait_until{ current_path == path }
end
