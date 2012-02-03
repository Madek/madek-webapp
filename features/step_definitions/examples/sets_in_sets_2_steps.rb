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
  step 'the set "%s" has the context "%s"' % [set_title, context_name]
end

Given /^the set called "([^"]*)" is child of "([^"]*)" and "([^"]*)"$/ do |set_title, parent_set_title_1, parent_set_title_2|
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

When /^I view the set "([^"]*)"$/ do |set_title|
  @set = MediaSet.find_by_title(set_title)
  visit resource_path(@set)
  step 'I should see "Set enthält"'
  step 'I should see "%s"' % @set.title
end

Then /^I see the available contexts "([^"]*)" and "([^"]*)"$/ do |title1, title2|
  step 'I follow "Kontexte"'
  step 'I should see "Diesem Set sind zusätzliche Kontexte mit Metadaten zugewiesen."'
  step 'I should see "%s"' % title1
  step 'I should see "%s"' % title2
end

Then /^I see some text explaining the consequences of assigning contexts to a set$/ do
  step 'I should see "So können für alle Medieneinträge, die in diesem Set enthalten sind, weitere inhaltliche Angaben gemacht werden. Darüber hinaus können alle Sets, die diesem Set zugewiesen werden, ebenfalls die ausgewählten zusätzlichen Kontexte erhalten."'
end

When /^I assign the context "([^"]*)" to the set "([^"]*)"$/ do |context_name, set_title|
  context_label = MetaContext.send(context_name).to_s
  
  step 'I follow "Kontexte"'
  wait_for_css_element('#contexts_tab input[@type="submit"]')
  find(:xpath, '//a[contains(., "%s")]/../input[@type="checkbox"]' % context_label).click 
  find('#contexts_tab input[@type="submit"]').click
end

Then /^I can choose to see more details about the context "([^"]*)"$/ do |context_name|
  context_label = MetaContext.send(context_name).to_s
  
  step 'I follow "Kontexte"'
  wait_for_css_element('#contexts_tab input[@type="submit"]')
  find(:xpath, '//a[contains(., "%s")]' % context_label)
end

Then /^the set "([^"]*)" has the context "([^"]*)"$/ do |set_title, context_name|
  @set = MediaSet.find_by_title(set_title)
  @set.title.should == set_title

  context = MetaContext.send(context_name)
  @set.individual_contexts.include?(context).should be_true 
end

Then /^the set still has the context called "([^"]*)"$/ do |context_name|
  step 'the set "%s" has the context "%s"' % [@set.title, context_name]
end
