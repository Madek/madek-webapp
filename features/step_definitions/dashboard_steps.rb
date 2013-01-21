Given /^I am on the dashboard$/ do
  visit "/"
end

Then /^I see a block of resources showing my content$/ do
  expect(find "#latest_user_resources_block" ).to be
end

Then /^There is a link to my resources$/ do
  expect(find "#latest_user_resources_block a[href*='/my/media_resources']").to be
end

When /^I follow the link to my resources$/ do
  (find "#latest_user_resources_block a[href*='/my/media_resources']").click
end

Then /^I am on the my resources page$/ do
  expect(current_path).to eq "/my/media_resources"
end

Then /^I see a block of resources showing my last imports$/ do
  expect(find "#latest_user_imports_block").to be
end


Then /^I see a block of resources showing my favorites$/ do
  expect(find "#user_favorite_resources_block").to be
end

Then /^There is a link to my favorites$/ do
  expect(find "#user_favorite_resources_block a[href*='/my/favorites']").to be
end

When /^I follow the link to my favorites page$/ do
  (find "#user_favorite_resources_block a[href*='/my/favorites']").click
end

Then /^I am on the my favorites$/ do
  expect(current_path).to eq "/my/favorites"
end


Then /^I see a block of my keywords$/ do
  expect(find "#user_keywords_block").to be
end

Then /^There is a link to my keywords$/ do
  expect(find "#user_keywords_block a[href*='/my/keywords']").to be
end

When /^I follow the link to my keywords$/ do
  (find "#user_keywords_block a[href*='/my/keywords']").click
end

Then /^I am on the my keywords page$/ do
  expect(current_path).to eq "/my/keywords"
end


Then /^I see a block of resources showing content assigned to me$/ do                                                                 [24/1916]
  expect(find "#user_entrusted_resources_block").to be
end

Then /^There is a link to content assigned to me$/ do
  expect(find "#user_entrusted_resources_block a[href*='/my/entrusted_media_resources']").to be
end

When /^I follow the link to content assigned to me$/ do
  (find "#user_entrusted_resources_block a[href*='/my/entrusted_media_resources']").click
end

Then /^I am on the content assigned to me page$/ do
  expect(current_path).to eq "/my/entrusted_media_resources"
end


Then /^I see a list of my groups$/ do
  expect(find "#my_groups_block").to be
end

Then /^There is a link to my groups$/ do
  expect(find "#my_groups_block a[href*='/my/groups']").to be
end

When /^I follow the link to my groups$/ do
  pending
  (find "#my_groups_block a[href*='/my/groups']").click
end

Then /^I am on the my groups page$/ do
  pending
  expect(current_path).to eq "/my/groups"
end
