Then /^the search results should (not )?contain "([^"]*)"$/ do |shouldnt_they, title|
  #find("#media_entry_results")
  #find("#detail_specification").text.include?(title).should == (shouldnt_they.blank? ? true : false)
  find("#results").text.include?(title).should == (shouldnt_they.blank? ? true : false)

  #group.users.include?(user).should == (shouldnt_they.blank? ? true : false)
end