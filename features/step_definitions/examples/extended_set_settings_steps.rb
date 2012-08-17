When /^I see the detail view of a set that I can edit$/ do
  @media_set = MediaResource.media_sets.accessible_by_user(@current_user, :edit).first
  visit media_resource_path @media_set
end

When /^I see the detail view of a set that I can edit which has no children$/ do
  @media_set = MediaResource.media_sets.accessible_by_user(@current_user, :edit).detect{|set| set.children.empty? }
  if @media_set.nil?
    steps %Q{
      When I create a set through the context actions
      Then I see a dialog with an input field for the title
      When I provide a title
      Then I can create a set with that title
      When I created that set
      Then Im redirectet to the detail view of that set
    }
    @media_set = MediaResource.media_sets.accessible_by_user(@current_user, :edit).detect{|set| set.children.empty? }
  end

  visit media_resource_path @media_set
end

Then /^I should see an information that this set is empty$/ do
  wait_until { find(".dialog .empty_results") }
  find(".dialog .close_dialog").click
  wait_until{ all(".dialog", :visible => true).empty? }
end

Then /^I can open the set cover dialog$/ do
  step 'I hover the context actions menu'
  find(".action_menu .action_menu_list a", :text => "Titelbild").click
end

Then /^I see a list of media resources which are inside that set$/ do
  @media_set.children.each do |child|
    find(".dialog tr", :text => child.title)
  end
end

When /^I choose one of that media resources$/ do
  last_element = all(".dialog tr").last
  @selected_child = MediaResource.find last_element["data-media_resource_id"].to_i
  last_element.find(".selection input").click
  find(".dialog .save").click
end

Then /^that media resource is displayed as cover of that set$/ do
  wait_until { all(".dialog", :visible => true).length == 0 }
  @media_set.out_arcs.where(cover:true).first.child_id.should == @selected_child.id
end

When /^I add media resources to an empty set$/ do
  @media_entry = MediaResource.media_entries.accessible_by_user(@current_user).first
  visit media_resource_path @media_entry
  step 'I open the selection widget for this entry'
  step 'I create a new set named "I add a media resource to that set"'
  step 'I submit the selection widget'
end

Then /^one of these media resources is set as the cover for that set automatically$/ do
  MediaSet.find_by_title("I add a media resource to that set").out_arcs.where(cover: true).first.child_id.should == @media_entry.id
end

When /^a set is empty$/ do
  @media_set = MediaSet.all.detect {|ms| ms.children.length == 0}
end

Then /^it has no cover$/ do
  @media_set.out_arcs.where(cover:true).should be_empty
end

When /^a set contains only sets$/ do
  @media_set = MediaSet.all.detect {|ms| ms.media_entries.length == 0 and ms.child_sets.length > 0 }
end

When /^a set has a cover$/ do
  @user = User.first
  @media_set = MediaResource.media_sets.accessible_by_user(@user, :edit).first
  @media_entry = MediaResource.media_entries.accessible_by_user(@user).first
  @media_set.children << @media_entry
end

Then /^that cover is displayed$/ do
  @media_set.out_arcs.where(cover:true).first.child.id.should == @media_entry.id
end

When /^I changed the layout$/ do
  find("#bar .layout .icon[data-type='list']").click
end

When /^I changed the sorting$/ do
  page.execute_script %Q{ $("#bar .sort a").show() }
  find("#bar .sort .title").click
end

When /^I save that display settings$/ do
  page.execute_script %Q{ $(".action_menu:first .action_menu_list").show() }
  find(".action_menu .action_menu_list a.saves_display_settings").click
  step 'I wait for the AJAX magic to happen'
end

When /^another user visits the detail view of that set$/ do
  step 'I am "Petra"'
  page.execute_script %Q{ delete sessionStorage.active_layout }
  visit media_resource_path @media_set
end

Then /^he sees the content of that set according to the saved display settings$/ do
  (find("#children")[:class] =~ /list/).should_not be_nil
  (find("#bar .sort a")[:class] =~ /title/).should_not be_nil
end