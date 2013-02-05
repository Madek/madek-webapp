When /^I click on the ZHdK\-Login$/ do
  find("a#zhdk-user-login-tab").click
  find("a#internal-login-link").click
end

Then /^I'm on the the ZHdK-Login page$/ do
  expect(current_url =~ /https:\/\/www\.zhdk\.ch\/\?agw/).to be
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

