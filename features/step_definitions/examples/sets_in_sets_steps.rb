# coding: UTF-8

Given /^I see some sets$/ do
  3.times do
    FactoryGirl.create :media_set, :user => @current_user
  end
  @current_user.media_sets.count.should == 3
  
  visit media_resources_path(:user_id => @current_user, :type => "media_sets")
  wait_for_css_element("div.page div.item_box")
  all(".item_box").size.should == 3
end

When /^I add them to my favorites$/ do
  @current_user.favorites.count.should == 0
  @current_user.favorites << @current_user.media_sets
  @current_user.favorites.count.should == 3
end

Then /^they are in my favorites$/ do
  @current_user.media_sets.reload.each do |set|
    @current_user.favorites.reload.include?(set).should == true
  end

  visit media_resources_path(favorites: true)
  wait_for_css_element("div.page div.item_box")
  all(".item_box").size.should == 3
end

Then /^I can open them and see that are set as favorite$/ do
  @current_user.favorites.each do |f|
    visit media_resource_path(f)
    step 'I should see "Set enthält"'
    find(".favorite_link .button_favorit_on")
  end
end

Given /^a context called "(.*)" exists$/ do |name|
  #@context = MetaContext.send(name)
  @context = MetaContext.where(:name => name).first
  @context.should_not be_nil
  @context.name.should == name
  @context.to_s.should_not be_empty
  #@context.to_s.should == name
end

When /^I look at a page describing this context$/ do
  visit meta_context_path(@context)
  step 'I should see "%s"' % @context
end

Then /^I see all the keys that can be used in this context$/ do
  find_link("Vokabular").click
  @context.meta_keys.for_meta_terms.each do |meta_key|
    definition = meta_key.meta_key_definitions.for_context(@context)
    label = definition.label
    step 'I should see "%s"' % label
  end
end

Then /^I see all the values those keys can have$/ do
  @context.meta_keys.for_meta_terms.each do |meta_key|
    meta_key.meta_terms.each do |meta_term|
      step 'I should see "%s"' % meta_term
    end
  end
end

Then /^I see an abstract of the most assigned values from media entries using this context$/ do
  find_link("Auszug").click
  find("#slider")
end

Given /^are some sets and entries$/ do
  steps %Q{
    And a set titled "My Act Photos" created by "max" exists
    And a entry titled "Me with Nothing" created by "max" exists
    And the last entry is child of the last set
 
    And a set titled "My Private Images" created by "max" exists
    And a entry titled "Me" created by "max" exists
    And the last entry is child of the last set
    And the last set is parent of the 1st set   
      
    And a set titled "My Public Images" created by "max" exists
    And a entry titled "My Profile Pic" created by "max" exists
    And the last entry is child of the 2nd set
    And the last entry is child of the last set
    
    And a set titled "Football Pics" created by "max" exists
    And a entry titled "Me and my Balls" created by "max" exists
    And the last entry is child of the last set
    And the last entry is child of the 2nd set
    And the last set is parent of the 3rd set
    
    And a set titled "Images from School" created by "max" exists
    And a entry titled "Me with School Uniform" created by "max" exists
    And the last entry is child of the last set
    
    And a set titled "This is a extreme long set title reaaaaaaly looooooong" created by "max" exists
    
    And a set was created at "18.01.1987" titled "Long time ago" by "max"
    And the last set is child of the 2nd set
  }
end

When /^I open the sets in sets tool$/ do
  steps %Q{
    When I open the "My Act Photos" set
    And I open the selection widget for this set
  }
  
  @current_set = MediaSet.find 1
  @user = User.last
  @accesible_sets = MediaSet.accessible_by_user(@user, :edit)
  @parent_sets = @current_set.parent_sets.accessible_by_user(@user, :edit)
end

Then /^I see all sets I can edit$/ do
  @accesible_sets.each do |set|
    steps %Q{
      Then I can read the sliced title of each set
    }
  end
end

Then /^I can see the owner of each set$/ do
  @accesible_sets.each do |set|
    steps %Q{
      Then I should see "#{set.user.name}"
    }
  end
end

Then /^I can see that selected sets are already highlighted$/ do
  @parent_sets.each do |set|
    assert find("label[title='#{set.title}']").has_xpath?('./..[@class="selected"]')
  end
end

Then /^I can choose to see additional information$/ do
  @parent_sets.each do |set|
    assert find("label[title='#{set.title}']")
  end
end

Then /^I can read the sliced title of each set$/ do
  @accesible_sets.each do |set|
    match_string = if set.title.length > 40
      "#{set.title.slice(0, 20)}...#{set.title.slice(set.title.length - 20, set.title.length)}"
    else
      set.title
    end
    steps 'Then I should see "%s"' % match_string
  end
end

Then /^I can see enough information to differentiate between similar sets$/ do
  @accesible_sets.each do |set|
    next if set = @current_set
    steps %Q{
      Then I can read the sliced title of each set
      And I can see the owner of each set
      And I can choose to see additional information
    }
    date_container = find("label[title='#{set.title}'] .created_at")
    unless set.created_at.strftime("%d.%m.%Y") == Date.today.strftime("%d.%m.%Y")
      date_container.should have_content(set.created_at.strftime("%d"))
      date_container.should have_content(set.created_at.strftime("%m"))
      date_container.should have_content(set.created_at.strftime("%Y"))   
    end
  end
end
      
Given /^some entries and sets are in my selection$/ do
  steps %Q{
    Given are some sets and entries
    When I go to the media entries
    And I check the media entry titled "My Profile Pic"
    And I check the media entry titled "Me and my Balls"
    And I check the media set titled "Long time ago"
  }
  @selected_entries = []
  MediaResource.all.each do |resource|
    if resource.title == "My Profile Pic" || resource.title == "Me and my Balls"
      @selected_entries << resource
    end
  end
  
  @selected_set = MediaSet.find(12)
  @possible_parents = @selected_entries.map do |entry|
    entry.media_sets - [@selected_set]
  end
end

Given /^they are in various different sets$/ do
  all_have_same_parents = true
  @possible_parents.each_with_index do |parent_group, index|
    (@possible_parents-parent_group).each do |other_parent_group|
      all_have_same_parents = false if (parent_group == other_parent_group) 
    end
  end
  
  assert all_have_same_parents==false
end

Then /^I open inside the batch edit the sets in sets widget$/ do
  steps %Q{
    And I open the selection widget for this batchedit
  }
  
  @current_set = MediaSet.find 1
  @user = User.last
  @accesible_sets = MediaSet.accessible_by_user(@user, :edit)
  @parent_sets = @current_set.parent_sets.accessible_by_user(@user, :edit)
end

Then /^I see the sets none of them are in$/ do
  (@accesible_sets-@possible_parents.flatten.uniq!-[@selected_set]).each do |set|
    assert_nil find("label[title='#{set.title}'] input")["checked"]
  end
end

Then /^I see the sets some of them are in$/ do
  intermediate_parents = @possible_parents.flatten.uniq! - @possible_parents.reduce(:&)
  intermediate_parents.each do |parent|
    assert find("label[title='#{parent.title}']").has_xpath?('./..[@class="intermediate"]')
    assert find("label[title='#{parent.title}'] .intermediate_pipe")
  end
end

Then /^I see the sets all of them are in$/ do
  all_of_them_are_in_parents = @possible_parents.reduce(:&) - [@selected_set]
  all_of_them_are_in_parents.each do |parent|
    assert find("label[title='#{parent.title}']").has_xpath?('./..[@class="selected"]')
  end
end

Then /^I can add all of them to one set$/ do
  target = (@possible_parents.flatten.uniq! - @possible_parents.reduce(:&)).first
  wait_until { find(".set.widget .list li") }
  step 'I select "%s" as parent set' % target.title
  step 'I submit the selection widget'
  step 'I open the selection widget for this batchedit'
  step 'the "%s" checkbox should be checked' % target.title.gsub(/\s/, "_")
end

Then /^I can remove all of them from one set$/ do
  target = (@possible_parents.flatten.uniq! - @possible_parents.reduce(:&)).first
  steps %Q{
     And I deselect "#{target.title}" as parent set
     And I submit the selection widget
     And I open the selection widget for this batchedit
     And the "#{target.title}" checkbox should not be checked
  }
end
