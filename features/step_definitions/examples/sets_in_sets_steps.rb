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
    find("label[title='#{set.title}']").has_xpath?('./..[@class="selected"]').should_not be_nil
  end
end

Then /^I can choose to see additional information$/ do
  @parent_sets.each do |set|
    find("label[title='#{set.title}']").should_not be_nil
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
  
  all_have_same_parents.should == false
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
    all("label").each do |label|
      if label["title"] == set.title
        label.find("input")["checked"].should == nil
      end
    end
  end
end

Then /^I see the sets some of them are in$/ do
  intermediate_parents = @possible_parents.flatten.uniq! - @possible_parents.reduce(:&)
  intermediate_parents.each do |parent|    
    all("label").each do |label|
      if label["title"] == parent.title
        label.has_css?(".intermediate_pipe").should == true
      end
    end

  end
end

Then /^I see the sets all of them are in$/ do
  all_of_them_are_in_parents = @possible_parents.reduce(:&) - [@selected_set]
  all_of_them_are_in_parents.each do |parent|
    all("label").each do |label|
      if label["title"] == parent.title
        label.has_css?(".selected").should == true
      end
    end

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


Given /^a few sets$/ do
  MediaSet.count.should > 0
end

When /^a set has no parents$/ do
  @top_level_set = MediaSet.all.detect {|x| x.parent_sets.empty? }
end

Then /^it is a top\-level set$/ do
  MediaSet.top_level.include?(@top_level_set)
end

When /^I view a grid of these sets$/ do
  visit media_resources_path()
end

When /^I examine my "([^"]*)" sets more closely$/ do |title|
  wait_for_css_element('.thumb_box')
  @media_set = MediaSet.find_by_title title
  page.execute_script "$(\"dd[title='#{title}']\").closest(\".item_box\").find(\".thumb_box_set\").trigger(\"mouseenter\")"
  wait_for_css_element('.set_popup')
end

Then /^I see relationships for this set$/ do
  @displayed_parent_sets = all(".set_popup .parents .resource")
  @display_child_entries = all(".set_popup .children .resource.media_entry")
  @display_child_sets = all(".set_popup .children .resource.media_set")
end

Then /^I see how many media entries that are viewable for me in this set$/ do
  find(".set_popup .children .text", :text => "#{(@media_set.media_entries.size-@display_child_entries.size)} weitere Medieneinträge")
end

Then /^I see how many sets that are viewable for me in this set$/ do
  find(".set_popup .children .text", :text => "#{(@media_set.child_sets.size-@display_child_sets.size)} weitere Sets")
end

Then /^I see how many sets that are viewable for me are parents of this set$/ do
  find(".set_popup .parents .text", :text => "#{(@media_set.parent_sets.size-@displayed_parent_sets.size)} weitere Sets")
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
  @current_user.authorized?(:edit, @set).should be_true
end

When /^I view the set "([^"]*)"$/ do |set_title|
  @set = MediaSet.find_by_title(set_title)
  visit media_resource_path(@set)
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
  find(:xpath, '//strong[contains(., "%s")]' % context_label).click 
  find('#contexts_tab input[@type="submit"]').click
end

Then /^I can choose to see more details about the context "([^"]*)"$/ do |context_name|
  context_label = MetaContext.send(context_name).to_s
  
  step 'I follow "Kontexte"'
  wait_for_css_element('#contexts_tab input[@type="submit"]')
  find(:xpath, "//strong[contains(., '#{context_label}')]/../../a")
end

Then /^the set "([^"]*)" has the context "([^"]*)"$/ do |set_title, context_name|
  @set = MediaSet.find_by_title(set_title)
  @set.title.should == set_title

  context = MetaContext.where(:name => context_name).first
  @set.individual_contexts.include?(context).should be_true 
end

Then /^the set still has the context called "([^"]*)"$/ do |context_name|
  step 'the set "%s" has the context "%s"' % [@set.title, context_name]
end

Then /^I see previews of the resources that are children of this set$/ do
  @display_child_entries.each do |child|
    child.find("img")["src"].should_not == "undefined"
    child.find("img")["src"].should_not be_nil
  end
end

Then /^I see previews of the resources that are parent of this set$/ do
  @displayed_parent_sets.each do |parent|
    parent.find("img")["src"].should_not == "undefined"
    parent.find("img")["src"].should_not be_nil
  end
end

When /^I hover those previews of children I see the title of those resources$/ do
  @display_child_entries.each do |child|
    child["title"].should_not == "undefined"
    child["title"].should_not be_nil
  end
end

When /^I hover those previews of parents I see the title of those resources$/ do
  @displayed_parent_sets.each do |parent|
    parent["title"].should_not == "undefined"
    parent["title"].should_not be_nil
  end
end

Given /^I open a set which has child media entries$/ do
  @set = MediaResource.accessible_by_user(@current_user).detect{|resource| resource.media_entries.accessible_by_user(@current_user).count > 0}
  visit media_set_path(@set)
end

Given /^I switch the list of the childs to the miniature view$/ do
  find("#bar .layout .icon[data-type='miniature']").click
end

Given /^I examine one of the child media entry more closely$/ do
  page.execute_script('$(".thumb_box").trigger("mouseenter")')
end

Then /^I see more information about that media entry popping up$/ do
  wait_until { find(".entry_popup") }
end