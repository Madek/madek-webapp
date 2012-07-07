When /^I open the admin interface$/ do
  visit admin_root_path
end

When /^I navigate to the people list$/ do
  find("header a", :text => "People").click
end

When /^I navigate to the users list$/ do
  find("header a", :text => "Users").click
end

When /^I see if there is already an associated user \(Edit\/Add User\)$/ do
  # OPTIMIZE
  find("th", :text => "Firstname")
  find("th", :text => "Lastname")
  find("th", :text => "Pseudonym")
  find("th", :text => "User")
end

When /^I create a new person$/ do
  find("a", :text => "New Person").click
end

When /^I create a new user for "(.*?)"$/ do |arg1|
  find("tr", :text => arg1).find("a", :text => "Create User").click
end

Then /^a new user with login "(.*?)" is created$/ do |arg1|
  @created_user = User.find_by_login(arg1)
  @created_user.should_not be_nil
end

Then /^a database login is created$/ do
  @created_user.password.should_not be_nil
  @created_user.zhdkid.should be_nil
end

Then /^the password is crypted$/ do
  @created_user.password.size.should == Digest::SHA1.hexdigest("test").size
  (@created_user.password =~ /\H/).should be_nil
end

When /^I edit the user$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I change login, email, password and comment$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the login, email, password and comment are changed$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I delete a user$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the user is deleted$/ do
  pending # express the regexp above with the code you wish you had
end
