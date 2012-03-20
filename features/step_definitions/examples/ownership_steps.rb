# coding: UTF-8



When /^I change the owner to "([^"]*)"$/ do |new_owner|
  @media_set = FactoryGirl.create :media_set, user: @current_user
  visit media_set_path @media_set
  step 'I open the permission lightbox'
  find(".users .line.add .button").click()
  find(".users .line.add input").set(new_owner)
  wait_for_css_element(".ui-autocomplete li a")
  find(".ui-autocomplete li a").click()
  find(".users .line .owner input").click()
  find("a.save").click()
end


Then /^I am no longer the owner$/ do
  sleep 1
  @media_set.reload.user.should_not == @current_user
end

Then /^the resource is owned by "([^"]*)"$/ do |owner|
  @media_set.reload.user.should == (User.find_by_login owner.downcase)
end


Given /^a resource owned by me$/ do
  @media_set = FactoryGirl.create :media_set, user: @current_user
end

Then /^I can use some interface to change the resource's owner to "([^"]*)"$/ do |new_owner|
  visit media_set_path(@media_set)
  step 'I open the permission lightbox'
  find(".users .line.add .button").click()
  find(".users .line.add input").set(new_owner)
  wait_for_css_element(".ui-autocomplete li a")
  find(".ui-autocomplete li a").click()
  find(".users .line .owner input").should_not be_nil
end


When /^I vist that resource's page$/ do
  visit resource_path(@media_set)
end

When /^I see a list of resources$/ do
  visit root_path
end

Then /^I can see if a resource is only visible for me$/ do
  find(".item_box .icon_status_perm_private")
end

Then /^I can see if a resource is visible for multiple other users$/ do
  find(".item_box .icon_status_perm_shared")
end

Then /^I can see if a resource is visible for the public$/ do
  find(".item_box .icon_status_perm_public")
end

Then /^I see a list of content owned by me$/ do
  find("#content_body .page_title_left", :text => "Meine Inhalte")
end

Then /^I see a list of content that can be managed by me$/ do
  find("#content_body2 .page_title_left", :text => "Mir anvertraute Inhalte")
end

Then /^I see a list of other people's content that is visible to me$/ do
  find("#content_body2 .page_title_left", :text => "Öffentliche Inhalte")
end

When /^I open the set called "([^"]*)"$/ do |set_title|
  visit media_set_path(@current_user.media_sets.find_by_title(set_title))

end

When /^I want to change the owner$/ do
  step 'I open the permission lightbox'
end

When /^I open the permission lightbox$/ do
  find(".open_permission_lightbox").click
  wait_for_css_element(".permission_lightbox .line")
end

Then /^I can choose a user as owner$/ do
  page.has_css?(".permission_view .users .line .owner input").should == true
  all(".groups .line .owner input").size >= 0
end

Then /^I can not choose any groups as owner$/ do
  all(".groups .line .owner input").size == 0
  all(".public .line .owner input").size == 0
end

When /^I open a media resource owned by someone else$/ do
  wait_for_css_element("#results_others .thumb_box")
  find("#results_others .thumb_box").click
end

Then /^I cannot change the owner$/ do
  step 'I open the permission lightbox'
  all(".permission_lightbox .owner").each do |owner_field|
    owner_field.find("input[disabled=disabled]") if owner_field.all("input").size>0
  end
end

When /^"([^"]*)" changes the resource's permissions for "([^"]*)" as follows:$/ do |owner, new_owner, table|
  visit resource_path(@resource)
  step 'I open the permission lightbox'
  find(".users .line.add .button").click()
  find(".users .line.add input").set(new_owner)
  wait_for_css_element(".ui-autocomplete li a")
  find(".ui-autocomplete li a").click()

  table.hashes.each do |perm| 
    if (perm["value"] == "false" and find(%Q@.users .line input##{perm["permission"]}@).selected?) \
      or (perm["value"] == "true" and (not find(%Q@.users .line input##{perm["permission"]}@).selected?))
        find(%Q@.users .line input##{perm["permission"]}@).click()
    end
  end
  find("a.save").click()
  sleep 1
end


Then /^the resource has the following permissions for "([^"]*)":$/ do |user_login, table|
  user = User.where("login = ?", user_login.downcase).first
  userpermission = Userpermission.where("user_id = ?",user.id).where("media_resource_id = ?",@resource.id).first
  table.hashes.each do |perm| 
    userpermission.send(perm["permission"]).to_s.should == perm["value"]
  end
end

When /^I open one of my resources$/ do
  wait_for_css_element("#content_body .thumb_box")
  find("#content_body .thumb_box").click
end

Then /^I should have all permissions$/ do
  all(".me .permission").each do |permission|
    permission.find("input[checked=checked]")
  end
end

When /^I create a resource$/ do
  step 'I upload a file'
  visit "/upload/permissions"
end

Then /^I am the owner of that resource$/ do
  pending
end

When /^I open a media entry$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I see who is the owner$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I open a media set$/ do
  pending # express the regexp above with the code you wish you had
end
