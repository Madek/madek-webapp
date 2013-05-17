Then(/^I can see exactly "(.*?)" included resources$/) do |snum|
  wait_until{ all("ul#ui-resources-list li.ui-resource").size == snum.to_i }
end

Then(/^I can see at least "(.*?)" included resources$/) do |snum|
  wait_until(3*Capybara.default_wait_time){ all("ul#ui-resources-list li.ui-resource").size >= snum.to_i }
end
