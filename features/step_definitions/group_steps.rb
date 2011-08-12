# coding: UTF-8

When /^I remove "([^"]*)" from the group$/ do |member|
  find(:css, "#members").find("li", :text => member).find("a", :text => 'Löschen').click
  sleep 0.8
end

When /^I wait for (\d+) seconds$/ do |num|
  sleep(num.to_f)
end

Then /^"([^"]*)" should (not )?be a member of the "([^"]*)" group$/ do |member_name, shouldnt_they, group_name|
  lastname, firstname = member_name.split(", ")
  person = Person.where(:lastname => lastname, :firstname => firstname).first
  user = person.user
  group = Group.where(:name => group_name).first
  group.users.include?(user).should == (shouldnt_they.blank? ? true : false)
end
