When /^I see a list of resources$/ do
  visit media_resources_path
  wait_until { all(".ui-resource").size > 0 }
end

When /^I switch to (.*?) view$/ do |vismode|
  find("[data-vis-mode='#{vismode}']").click
end
