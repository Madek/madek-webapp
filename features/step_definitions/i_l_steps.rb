# -*- encoding : utf-8 -*-

Then /^I logout\.$/ do
  find(".app-header .ui-header-user a").click
  find("a[href='/logout']").click
end


