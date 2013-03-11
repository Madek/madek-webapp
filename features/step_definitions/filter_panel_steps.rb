Then /^I can see the filter panel$/ do
  wait_until{ all(".filter-panel").size > 0}
end

Then /^The filter panel contains a search input$/ do
  wait_until{ all(".filter-panel .filter-search").size > 0}
end

Then /^The filter panel contains a top\-filter\-list$/ do
  wait_until{ all(".filter-panel ul.top-filter-list").size > 0}
end

Then /^The filter panel contains the top filter "(.*?)"$/ do |text|
  wait_until{ all(".filter-panel ul.top-filter-list", text: text).size > 0}
end

Given /^I remember the number of resources$/ do
  @resources_counter = find("#resources_counter").text.to_i
end

Given /^I wait for the number of resources to change$/ do
  wait_until(3){ 
    if all("#resources_counter").size > 0
      find("#resources_counter").text.to_i != @resources_counter 
    end
  }
end

Then /^the number or resources is lower then before$/ do
  expect(find("#resources_counter").text.to_i).to be < @resources_counter
end
