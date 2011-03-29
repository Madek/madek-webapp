When /^I remove "([^"]*)" from the group$/ do |member|
  find(:css, "#members").find("li", :text => member).find("a", :text => 'Löschen').click
  sleep 0.8
end

When /^I wait for (\d+) seconds$/ do |num|
  sleep(num.to_f)
end