When /^I go to my groups$/ do
  visit my_groups_path
end

When /^I try to create a new group by using the context primary action$/ do
  find(".ui-body-title-actions .primary-button").click
  step 'I wait for the dialog to appear'
end

When /^I provide a name$/ do
  @name = Faker::Name.last_name
  find("input[name='name']").set @name
end

Then /^the group is created$/ do
  wait_until {all(".modal-backdrop").size == 0}
  expect{ @current_user.groups.find_by_name("@name") }.to be
end

When /^I don't provide a name$/ do
  find("input[name='name']").set ""
end

Then /^I see an error that I have to provide a name for that group$/ do
  step 'I see an error alert'
end

When /^I edit one group$/ do
  @group = @current_user.groups.first
  find(".ui-workgroups tr[data-id='#{@group.id}'] .button.edit-workgroup").click
  step 'I wait for the dialog to appear'
end

Then /^I can add a new member to the group$/ do
  @added_user = User.where(User.arel_table[:id].not_eq(@current_user.id)).where(User.arel_table[:id].not_in(@group.users.map(&:id))).first
  find("input#add-user").set @added_user.to_s
  find("ul.ui-autocomplete li a", text: @added_user.to_s).click
end

Then /^I can delete an existing member from the group$/ do
  @removed_user = User.where(User.arel_table[:id].not_eq(@current_user.id)).where(User.arel_table[:id].in(@group.users.map(&:id))).first
  find("#user-list tr", :text => @removed_user.to_s).find(".button[data-remove-user]").click
  wait_until{all("#user-list tr", :text => @removed_user.to_s).size == 0}
end

Then /^the group members are updated$/ do
  step 'I wait for the dialog to disappear'
  expect{@group.users.find(@added_user.id)}.to be
  expect{@group.users.find(@removed_user.id)}.to raise_error
end

When /^I remove all members of a specific group except myself$/ do
  all_users_expect_myself = @group.users.where(User.arel_table[:id].not_eq(@current_user.id))
  all_users_expect_myself.each do |user|
    find("#user-list tr", :text => user.to_s).find(".button[data-remove-user]").click
  end
  wait_until{all("#user-list tr").size == 1}
  step 'I click the primary action of this dialog'
end

When /^I delete that group$/ do
  find(".ui-workgroups tr[data-id='#{@group.id}'] .button.delete-workgroup").click
  step 'I wait for the dialog to appear'
  step 'I click the primary action of this dialog'
  step 'I wait for the dialog to disappear'
end

Then /^the group is deleted$/ do
  expect{ Group.find @group.id }.to raise_error
end

When /^I delete a group where I'm not the only remaining member$/ do
  @group = @current_user.groups.joins("INNER JOIN groups_users AS gu2 ON groups.id = gu2.group_id").group("groups.id, gu2.group_id").having("count(gu2.group_id) > 1").first
  find(".ui-workgroups tr[data-id='#{@group.id}'] .button.delete-workgroup").click
end

Then /^I see an error message that the group cannot be deleted if there are more than (\d+) members$/ do |arg1|
  step 'I see an error alert'
end

Then /^the group is not deleted$/ do
  expect{ Group.find @group.id }.not_to raise_error
end

When /^I change the group name$/ do
  find("#show-edit-name").click
  @name = Faker::Name.last_name
  find("input#group-name").set @name
end

Then /^the group name is changed$/ do
  step 'I wait for the dialog to disappear'
  expect(@group.reload.name).to eq @name
end

When /^I make the group name empty$/ do
  find("#show-edit-name").click
  find("input#group-name").set ""
end

Then /^I see an error message that the group name has to be present$/ do
  step 'I see an error alert'
end

Then /^the group name is not changed$/ do
  expect(@group.reload.name).not_to eq @name
end