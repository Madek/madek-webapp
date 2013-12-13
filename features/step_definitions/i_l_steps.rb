# -*- encoding : utf-8 -*-

Then /^I logout\.$/ do
  find(".app-header .ui-header-user a").click
  find("a#sign-out").click
end

When /^I logout$/ do
  step "I go to the home page"
  step "I logout."
end
