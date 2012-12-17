Then /^I should see the save and continue button twice$/ do
  all("#save_meta_data.next").size.should == 2
end