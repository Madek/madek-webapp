# -*- encoding : utf-8 -*-
#
 
Then /^(?:|I )fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    step %{I fill in "#{name}" with "#{value}"}
  end
end

When /^I filter media entries with custom url$/ do
  custom_url = FactoryGirl.create :custom_url
  step %Q{I set the input with the name "filter[search_term]" to "#{custom_url.id}" and submit}
  step %Q{I can see only results containing "#{custom_url.media_resource.title}" term}
end

Then /^I follow the link to content assigned to me$/ do
  (find "#user_entrusted_resources_block a[href*='/my/entrusted_media_resources']").click
end
  
Then /^I follow the first link to create a new user$/ do
  all("a",text:"Create User").first.click
end

Then /^I follow the link to my groups$/ do
  (find"a[href*='/my/groups']").click
end

Then /^I follow the link to my keywords$/ do
  (find "#user_keywords_block a[href*='/my/keywords']").click
end

Then /^I follow the link to my resources$/ do
  (find "#latest_user_resources_block a[href*='/my/media_resources']").click
end

Then /^I follow the link to my favorites page$/ do
  (find "#user_favorite_resources_block a[href*='/my/favorites']").click
end

Then /^I follow the link with the text "(.*?)"$/ do |text|
  find("a",text: text).click
end


