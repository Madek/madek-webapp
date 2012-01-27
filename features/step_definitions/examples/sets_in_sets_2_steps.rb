# coding: UTF-8

Given /^a few sets and entries$/ do
  # sets and entries are there thanks to the example data!
  assert MediaSet.count > 0
  assert MediaEntry.count > 0
end

When /^I view a grid of these sets$/ do
  
end

When /^I examine one of the sets more closely$/ do
end

Then /^I see relationships for this set$/ do
end

Then /^I see how many media entries that are viewable for me in this set$/ do
end

Then /^I see how many sets that are viewable for me in this set$/ do
end

Then /^I see how many sets that that are viewable for me are parents of this set$/ do
end