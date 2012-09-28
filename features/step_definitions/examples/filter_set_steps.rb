Then /^I can choose to save the configuration of the filters as a new set$/ do
  step "all the hidden items become visible"
  find(".action_menu li a", :text => "Neues Set").click
end

When /^I choose to save the filter configuration$/ do
  find(:xpath, "//input[@name='as_filterset']").click
end

Then /^I am prompted for the name of the new set that is thus created$/ do
  @current_user.media_resources.where(type: "FilterSet").count.should be_zero
  @fs_title = "My FilterSet"
  step 'I fill in "title" with "%s"' % @fs_title 
  step 'I press "Erstellen"'
  wait_until { find("#set_info") }
  @current_user.media_resources.where(type: "FilterSet").count.should == 1
end

When /^I look at a filter set$/ do
  fs = FactoryGirl.create :filter_set_with_title, user: @current_user, settings: {filter: {public: "true"}}
  visit media_resource_path(fs)
end