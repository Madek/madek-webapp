Then /^I can see at least one link to create a new user$/ do
  expect(all("a",text:"Create User").size).to be > 0
end

When /^I follow the first link to create a new user$/ do
  all("a",text:"Create User").first.click
end

When /^I open the admin\/users interface$/ do
  visit "admin/users"
end

When /^I delete a user$/ do
  all("a",text: "Delete").first.click
end

When /^I edit a user$/ do
  all("a",text: "Edit").first.click
end

When /^I set the usage terms accepted at to next year$/ do
  find('select#user_usage_terms_accepted_at_1i').select((Time.now.year + 1).to_s)
  find('select#user_usage_terms_accepted_at_2i').select("Januar")
  find('select#user_usage_terms_accepted_at_3i').select("1")
  find('select#user_usage_terms_accepted_at_4i').select("00")
  find('select#user_usage_terms_accepted_at_5i').select("00")
end

