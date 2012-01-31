# coding: UTF-8

Given /^a few sets and entries$/ do
  # sets and entries are there thanks to the example data!
  #assert MediaSet.count > 0
  #assert MediaEntry.count > 0
end

Given /^a few sets$/ do
  assert MediaSet.count > 0
end

When /^a set has no parents$/ do
  @top_level_set = MediaSet.all.detect {|x| x.parent_sets.empty? }
end

Then /^it is a top\-level set$/ do
  MediaSet.top_level.include?(@top_level_set)
end

When /^I view a grid of these sets$/ do
  pending
end

When /^I examine one of the sets more closely$/ do
  pending
end

Then /^I see relationships for this set$/ do
  pending
end

Then /^I see how many media entries that are viewable for me in this set$/ do
  pending
end

Then /^I see how many sets that are viewable for me in this set$/ do
  pending
end

Then /^I see how many sets that that are viewable for me are parents of this set$/ do
  pending
end


Given /^a set called "([^"]*)" that has the context "([^"]*)"$/ do |set_title, context_name|
  @set = MediaSet.find_by_title(set_title)
  @set.title.should == set_title

  @context = MetaContext.send(context_name)
  @set.individual_contexts.include?(@context).should be_true 
end

Given /^a set called "([^"]*)" which is child of "([^"]*)" and "([^"]*)"$/ do |set_title, parent_set_title_1, parent_set_title_2|
  @set = MediaSet.find_by_title(set_title)
  
  @parent_set_1 = MediaSet.find_by_title(parent_set_title_1)
  @parent_set_1.child_sets.include?(@set).should be_true
  
  @parent_set_2 = MediaSet.find_by_title(parent_set_title_2)
  @parent_set_2.child_sets.include?(@set).should be_true
end

Given /^I can edit the set "([^"]*)"$/ do |set_title|
  @set = MediaSet.find_by_title(set_title)
  Permissions.authorized?(@current_user, :edit, @set).should be_true
end