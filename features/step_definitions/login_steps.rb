When /^I click on the ZHdK\-Login$/ do
  find("a#zhdk-user-login-tab").click
end

When /^I click on the database login tab$/ do
  find("#database-user-login-tab").click
end

When /^I click the submit button$/ do
  find("button[type='submit']").click
end

Then /^I am logged in$/ do
  expect(find("a[href='/logout']")).to be
end


Then /^There is a link to the "(.*?)" path$/ do |path|
  expect("a[href='#{path}']").to be
end
