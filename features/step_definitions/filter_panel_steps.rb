When /^I use some filters$/ do
  @used_filter = []
  step 'I open the filter'
  (1..3).to_a.each do
    wait_until { page.evaluate_script("jQuery.active") == 0 }
    wait_until { all(".filter-panel *[data-value]:not(.active)").size > 0}
    filter_item = all(".filter-panel *[data-value]:not(.active)").shuffle.first
    context_element = filter_item.find(:xpath, ".//ancestor::*[@data-context-name]")
    key_element = filter_item.find(:xpath, ".//ancestor::*[@data-key-name]")
    @used_filter.push :key_name => key_element["data-key-name"],
                      :context => context_element["data-context-name"], 
                      :value => filter_item["data-value"]
    context_element.find("a").click unless context_element.find("a")[:class] =~ /open/
    key_element.find("a").click unless key_element.find("a")[:class] =~ /open/
    filter_item.click
  end
end

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

Given /^I remember the count for the filter "(.*?)"$/ do |filter|
  @count= find("li.resources_filter",text: filter).find(".resources_count").text.to_i
end

Then /^the number or resources is equal to the remembered filter count$/ do
  expect(find("#resources_counter").text.to_i).to eq @count
end


Then /^the number or resources is equal to the remembered number of resources$/ do
  expect(find("#resources_counter").text.to_i).to eq  @resources_counter
end

When /^I open the filter$/ do
  wait_until { all(".ui-resource").size > 0 }
  find("#ui-side-filter-toggle").click if all("#ui-side-filter-toggle.active").size == 0
  wait_until { all(".ui-side-filter-item").size > 0 }
end

When /^I select the any-value checkbox for a specific key$/ do
  @any_value_el = all(".any-value").shuffle.first
  context_name = @any_value_el.find(:xpath, ".//ancestor::*[@data-context-name]")["data-context-name"]
  key_name = @any_value_el.find(:xpath, ".//ancestor::*[@data-key-name]")["data-key-name"]
  @meta_key = MetaKey.find_by_id key_name
  @any_value_el.find(:xpath, ".//ancestor::*[@data-context-name]").click
  @any_value_el.find(:xpath, ".//ancestor::label").click
  wait_until { all(".ui-resource").size > 0 }
end

Then /^the list shows only resources that have any value for that key$/ do
  all(".ui-resource[data-id]").each do |element|
    media_resource = MediaResource.find element["data-id"]
    media_resource.meta_data.where(:meta_key_id => @meta_key.id).size.should > 0
  end
end
