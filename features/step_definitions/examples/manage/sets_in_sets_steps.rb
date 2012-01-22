# coding: UTF-8

Given /^I see some sets$/ do
  3.times do
    FactoryGirl.create :media_set, :user => @current_user
  end
  @current_user.media_sets.count.should == 3
  
  visit user_resources_path(@current_user, :type => "media_sets")
  wait_for_css_element("div.page div.item_box")
  all(".item_box").size.should == 3
end

When /^I add them to my favorites$/ do
  @current_user.favorites.count.should == 0
  @current_user.favorites << @current_user.media_sets
  @current_user.favorites.count.should == 3
end

Then /^they are in my favorites$/ do
  @current_user.favorites.reload.should == @current_user.media_sets.reload

  visit favorites_resources_path
  wait_for_css_element("div.page div.item_box")
  all(".item_box").size.should == 3
end

Given /^a context$/ do
  name = "Landschaftsvisualisierung"
  @context = MetaContext.send(name)
  @context.should_not be_nil
  @context.name.should == name
  @context.to_s.should_not be_empty
  @context.to_s.should == name
end

When /^I look at a page describing this context$/ do
  visit meta_context_path(@context)
  page.should have_content(@context.to_s)
end

Then /^I see all the keys that can be used in this context$/ do
  find_link("Vokabular").click
  @context.meta_keys.for_meta_terms.each do |meta_key|
    definition = meta_key.meta_key_definitions.for_context(@context)
    label = definition.meta_field.label
    page.should have_content(label)
  end
end

Then /^I see all the values those keys can have$/ do
  @context.meta_keys.for_meta_terms.each do |meta_key|
    meta_key.meta_terms.each do |meta_term|
      page.should have_content(meta_term.to_s)
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
    And the last entry is child of the last set
    
    And a set titled "Football Pics" created by "max" exists
    And a entry titled "Me and my Balls" created by "max" exists
    And the last entry is child of the last set
    And the last set is parent of the 3rd set
    
    And a set titled "Images from School" created by "max" exists
    And a entry titled "Me with School Uniform" created by "max" exists
    And the last entry is child of the last set
    
    And a set titled "This is a extreme long set title reaaaaaaly looooooong" created by "max" exists
    
    And a set was created at "18.01.1987" titled "Long time ago" by "max"
  }
end

When /^I open the sets in sets tool$/ do
  steps %Q{
    When I open the "My Act Photos" set
    And I open the selection widget for this set
  }
  
  @current_set = MediaSet.find 1
  @user = User.last
  @accsible_sets = MediaSet.accessible_by_user(@user, :edit)
  @parent_sets = @current_set.parent_sets.accessible_by_user(@user, :edit)
end

Then /^I see all sets I can edit$/ do
  @accsible_sets.each do |set|
    steps %Q{
      Then I can read the first 30 characters of each set title
    }
  end
end

Then /^I can see the owner of each set$/ do
  @accsible_sets.each do |set|
    steps %Q{
      Then I should see "#{set.user.name}"
    }
  end
end

Then /^I can see that selected sets are already highlighted$/ do
  @parent_sets.each do |set|
    assert find("[title='#{set.title}']").has_xpath?('./..[@class="selected"]')
  end
end

Then /^I can choose to see additional information$/ do
  @parent_sets.each do |set|
    assert find("[title='#{set.title}']")
  end
end

Then /^I can read the first 30 characters of each set title$/ do
  @accsible_sets.each do |set|
    steps %Q{
      Then I should see "#{set.title[0..30]}"
    }
  end
end

Then /^I can see enough information to differentiate between similar sets$/ do
  @accsible_sets.each do |set|
    next if set = @current_set
    steps %Q{
      Then I can read the first 30 characters of each set title
      And I can see the owner of each set
      And I can choose to see additional information
    }
    date_container = find("[title='#{set.title}'] .created_at")
    unless set.created_at.strftime("%d.%m.%Y") == Date.today.strftime("%d.%m.%Y")
      date_container.should have_content(set.created_at.strftime("%d"))
      date_container.should have_content(set.created_at.strftime("%m"))
      date_container.should have_content(set.created_at.strftime("%Y"))   
    end
  end
end
      
Given /^multiple resources are in my selection$/ do
  steps %Q{
    Given are some sets and entries
    When I go to the media entries
    And I check the media entry titled "My Profile Pic"
    And I check the media entry titled "Me and my Balls"
    And I open the selection widget for this batchedit
  }
end

Given /^they are in various different sets$/ do
  binding.pry
  # check if the sets in selection are in different sets
end

Then /^I see the sets none of them are in$/ do
  # not checked
  # not selected
end

Then /^I see the sets some of them are in$/ do
  # is intermdiate state
  # has intermediate pipe
end

Then /^I see the sets all of them are in$/ do
  # checked
  # selected 
end

Then /^I can add all of them to one set$/ do
   # link
   # submit
   # check
end

Then /^I can remove all of them from one set$/ do
   # revert
end
