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
