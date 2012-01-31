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


Given /^a set called "([^"]*)" that has the context "([^"]*)"$/ do |set_title, context_name|
  @set = MediaSet.find_by_title(set_title)
  @set.title.should == set_title

  @context = MetaContext.send(context_name)
  @set.individual_contexts.include?(@context).should == true 
end