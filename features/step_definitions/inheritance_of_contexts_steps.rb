When /^I put a set A that has media entries in set B that has any context$/ do
  @media_set_a = @current_user.media_sets.detect{|ms| ms.individual_contexts.count == 0 and ms.child_media_resources.media_entries.count > 0}
  @media_set_b = @current_user.media_sets.detect{|ms| ms.individual_contexts.count > 0}
  visit media_set_path(@media_set_a)
  step 'I open the organize dialog'
  find("[name='search_or_create_set']").set @media_set_b.title
  wait_until {all("#parent_resource_#{@media_set_b.id}").size > 0}
  find("#parent_resource_#{@media_set_b.id}").click
  step 'I submit'
  step 'I wait for the dialog to disappear'
end

Then /^the set A inherits all the contexts of the set B$/ do
  find("a[href='#{inheritable_contexts_media_set_path(@media_set_a)}']").click
  @media_set_b.individual_contexts.each do |context|
    page.should have_content context.label.to_s
    find("a[href='#{context_path context}']")
  end
end

Then /^all media entries contained in set A (doesnt have that context anymore|have all contexts of set A)$/ do |they_have_it|
  they_have_it = if they_have_it == "have all contexts of set A" then true else false end
  @media_set_a.child_media_resources.media_entries.accessible_by_user(@current_user).each do |media_entry|
    visit context_group_media_entry_path media_entry, "Kontexte"
    @media_set_a.individual_contexts.each do |context|
      if they_have_it
        page.should have_content context.label
      else
        page.should_not have_content context.label
      end
    end
  end
end

When /^I remove a set A from a set B from which set A is inheriting a context$/ do
  step 'I put a set A that has media entries in set B that has any context'
  @individual_context = @media_set_b.individual_contexts.first
  visit media_set_path(@media_set_a)
  step 'I open the organize dialog'
  wait_until {all("#parent_resource_#{@media_set_b.id}").size > 0}
  find("#parent_resource_#{@media_set_b.id}").click
  step 'I submit'
  step 'I wait for the dialog to disappear'
end

Then /^this context is removed from set A$/ do
  expect(@media_set_a.individual_contexts.include?(@individual_context)).to be_false
end

When /^I edit the contexts of a set that has contexts$/ do
  @media_set = @current_user.media_sets.detect{|ms| ms.individual_contexts.count > 0}
  @individual_contexts = @media_set.individual_contexts
  visit inheritable_contexts_media_set_path @media_set
end

When /^I disconnect any contexts from that set$/ do
  @individual_contexts.each do |context|
    find("input[value='#{context.id}']").click
  end
  step 'I submit'
end

Then /^those contexts are no longer connected to that set$/ do
  @individual_contexts.each do |context|
    expect(@media_set.reload.individual_contexts.include? context).to be_false
  end
end

Then /^all media entries contained in that set do not have the disconnected contexts any more$/ do
  @media_set.child_media_resources.media_entries.each do |media_entry|
    @individual_contexts.each do |context|
      expect(media_entry.individual_contexts.include? context).to be_false
    end
  end
end
