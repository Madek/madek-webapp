# coding: UTF-8


Given /^I see some sets$/ do
  @user = FactoryGirl.create :user
  3.times do
    FactoryGirl.create :media_set, :user => @user
  end
  @user.media_sets.count.should == 3
  
  # TODO gui
  pending
  # visit user_resources_path(@user, :type => "media_sets")
  # all(".thumb_box_set").size.should == 3
end

When /^I add them to my favorites$/ do
  @user.favorites.count.should == 0
  @user.favorites << @user.media_sets
  @user.favorites.count.should == 3
end

Then /^they are in my favorites$/ do
  @user.favorites.reload.should == @user.media_sets.reload
end

##########################################################################

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

##########################################################################
