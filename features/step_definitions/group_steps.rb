# coding: UTF-8

When /^I remove "([^"]*)" from the group$/ do |member|
  find(".member .fullname", :text => member).find(:xpath, "..").find(".button.remove").click
end

Then /^"([^"]*)" should (not )?be a member of the "([^"]*)" group$/ do |member_name, shouldnt_they, group_name|
  lastname, firstname = member_name.split(", ")
  person = Person.where(:lastname => lastname, :firstname => firstname).first
  user = person.user
  group = Group.where(:name => group_name).first
  group.users.include?(user).should == (shouldnt_they.blank? ? true : false)
end

When /^I edit the "(.*?)" group$/ do |name|
  find("li.group p", :text => name).find(:xpath, "..").find("button.edit").click
end
