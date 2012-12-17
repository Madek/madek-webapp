Then /^I see a selection of the images of the teaser set$/ do
  expect( find("#teaser-set").all("img").size).to be > 0
end

Then /^I see at most three elements of the catalog$/ do
  expect( find("#catalog .grid").all("li.ui-resource").size ).to be > 0
  expect( find("#catalog .grid").all("li.ui-resource").size ).to be < 3
end

Then /^I see sets of the featured sets$/ do
  expect( find("#featured-set .grid").all("li.ui-resource").size ).to be > 0
end

Then /^I see new content$/ do
  expect( find("#latest-media-entries .grid").all("li.ui-resource").size ).to be > 0
end

Then /^I see a ZHdK\-Login$/ do
  expect(find "#internal-user" ).to be
end

Then /^I see a database login$/ do
  expect(find "#external-user" ).to be
end

Then /^I see an explore tab$/ do
  expect(find "a#to-explore").to be
end

Then /^I see an help tab$/ do
  expect(find "a#to-help").to be
end

When /^I click on show me more of the catalog$/ do
  find("#catalog a").click
end


Then /^I am on the catalog page$/ do
  expect(find ".app.view-explore-catalog").to be
end

When /^I click on show me more of the featured sets$/ do
  find("#featured-set a").click
end


When /^I click on the explore tab$/ do
  find("a#to-explore").click
end

Then /^I am on the explore page$/ do
  expect(current_path).to eq "/explore"
end

When /^I click on the help tab$/ do
  find("a#to-help")
end

Then /^I am on the help page$/ do
  binding.pry
end

Then /^I am on the featured sets set page$/ do
  expect(current_path).to eq "/explore/featured_set"
end

When /^I click on show me more of new content$/ do
  binding.pry
end

Then /^I am on the new content page$/ do
  binding.pry
end
