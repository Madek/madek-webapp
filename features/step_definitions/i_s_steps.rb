# -*- encoding : utf-8 -*-


Then /^I save these changes$/ do
  find(".primary-button", :text => "Filtereinstellungen speichern").click
end

Then /^I use the "(.*?)" context action$/ do |context_name|  
  find("a",text: "Weitere Aktionen").click
  find("a",text: context_name).click
end

Then /^I scroll all the way down and click on "(.*?)"$/ do |text|
  page.execute_script "window.scrollBy(0,10000)"
  find("a,button",text: text).click
end

Then /^I select "(.*?)" from "(.*?)"$/ do |text, class_name|
  find("select.#{class_name}").select(text)
end

Then /^I select the any-value checkbox for a specific key$/ do
  @any_value_el = all(".any-value").shuffle.first
  context_name = @any_value_el.find(:xpath, ".//ancestor::*[@data-context-name]")["data-context-name"]
  key_name = @any_value_el.find(:xpath, ".//ancestor::*[@data-key-name]")["data-key-name"]
  @meta_key = MetaKey.find_by_id key_name
  @any_value_el.find(:xpath, ".//ancestor::*[@data-context-name]").click
  @any_value_el.find(:xpath, ".//ancestor::label").click
  wait_until { all(".ui-resource").size > 0 }
end

Then /^I select "(.*?)" of the label select options$/ do |value|
  find("a.primary-button").click()
  find("#show_labels").select(value)
end


Then /^I set the autocomplete\-input with the name "(.*?)" to "(.*?)"$/ do |name, value|
  find("input[name='#{name}']").set(value)
  page.execute_script %Q{ $("input[name='#{name}']").trigger("change") }
end

Then /^I set the input with the name "(.*?)" to "(.*?)"$/ do |name, value|
  find("input[name='#{name}']").set(value)
  # page.execute_script %Q{ $("input[name='#{name}']").trigger("change") }
end

Then /^I set the input with the name "(.*?)" to "(.*?)" and submit$/ do |name, value|
  find("input[name='#{name}']").set(value)
  find(:xpath, "//input[@name='#{name}']/ancestor::form").find("input[type='submit']").click()
end

Then /^I set the input in the fieldset with "(.*?)" as meta\-key to "(.*?)"$/ do |meta_key_id, value|
  find("fieldset[data-meta-key='#{meta_key_id}']").find("input,textarea",visible: true).set(value)
end

Then /^I submit$/ do
  all("form").last.find("[type='submit']").click
end

Then /^I switch to (.*?) view$/ do |vismode|
  find("[data-vis-mode='#{vismode}']").click
end

Given(/^I switch to uberadmin modus$/) do
  find("#user-action-button").click
  find("a#switch-to-uberadmin").click
end

When(/^I select "(.*?)" option from Sort by select$/) do |option|
  select(option, from: 'sort_by')
end
