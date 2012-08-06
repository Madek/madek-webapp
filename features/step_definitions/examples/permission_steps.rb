Given /^a resource owned by "([^"]*)"$/ do |persona|
  owner = User.where("login=?",persona.downcase).first
  @resource = FactoryGirl.create :media_entry, user: owner
end

Given /^a resource$/ do
  owner = FactoryGirl.create :user
  @resource = FactoryGirl.create :media_entry, user: owner
end

Given /^a set owned by "([^"]*)"$/ do |persona|
  owner = User.where("login=?",persona.downcase).first
  @resource = FactoryGirl.create :media_set, user: owner
end

Given /^a set named "([^"]*)" owned by "([^"]*)"$/ do |title, persona|
  owner = User.where("login=?",persona.downcase).first
  @resource = FactoryGirl.create(:media_set,
                      user: owner, 
                      meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: title}})
end

Given /^a set named "([^"]*)"$/ do |title|
  owner = FactoryGirl.create :user
  @resource = FactoryGirl.create(:media_set,
                      user: owner, 
                      meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: title}})
end

Given /^the resource has the following permissions:$/ do |table|
  table.hashes.each do |hash|
    persona = hash[:user]
    permission = hash[:permission]
    bool_value = hash[:value] == "true"
    user = User.where("login=?",persona.downcase).first
    up = Userpermission.scoped.where(:user_id => user.id, :media_resource_id => @resource.id).first
    up = Userpermission.create media_resource: @resource, user: user if up.blank?  
    up.update_attributes permission => bool_value
  end
end

Then /^"([^"]*)" can ([^"]*) the resource$/ do |user, permission|
  visit "/media_resources/#{@resource.id}/"
  step 'I open the permission lightbox'
  find(".me .line .permissions .#{permission} input").checked?
end

Then /^"([^"]*)" is the owner of the resource$/ do |user|
  visit "/media_resources/#{@resource.id}/"
  step 'I open the permission lightbox'
  find(".me .line .owner input").checked?
end

When /^"([^"]*)" adds the set "([^"]*)" to the set "([^"]*)"$/ do |persona,set_title_1, set_title_2|
  step 'I view the set "%s"' % set_title_1
  step 'I open the selection widget for this set'
  step 'I select "%s" as parent set' % set_title_2
  step 'I submit the selection widget'
end

Then /^"([^"]*)" is in "([^"]*)"$/ do |set_title_1, set_title_2|
  step 'I view the set "%s"' % set_title_1
  find(".set_parents_title").click()
  page.should have_content set_title_2 
end

Given /^I can view "([^"]*)" by "([^"]*)"$/ do |resource_title, user_name|
  owner = User.where("login=?",user_name.downcase).first
  resource = MediaResource.find_by_title(resource_title).first
  visit media_resource_path(resource)
  
  if resource.is_a? MediaSet
    page.should have_css("#info_tab h3", :text => resource_title)
  elsif resource.is_a? MediaEntry
    page.should have_css("h2.title", :text => resource_title)
  end
end

Given /^I can not view "([^"]*)" by "([^"]*)"$/ do |resource_title, user_name|
  owner = User.where("login=?",user_name.downcase).first
  resource = MediaResource.find_by_title(resource_title).first
  visit media_resource_path(resource)
  
  URI.parse(current_url).path.should == root_path
end

Then /^I can not view that resource$/ do
  visit media_resource_path(@resource)
  URI.parse(current_url).path.should == root_path
end

Given /^"([^"]*)" changes the resource's groupermissions for "([^"]*)" as follows:$/ do |user, group_name, table|
  visit media_resource_path(@resource)
  step 'I open the permission lightbox'
  find(".groups .line.add .button").click()
  find(".groups .line.add input").set(group_name)
  wait_for_css_element(".ui-autocomplete li a")
  find(".ui-autocomplete li a").click()

  table.hashes.each do |perm| 
    if (perm["value"] == "false" and find(%Q@.groups .line input##{perm["permission"]}@).selected?) \
      or (perm["value"] == "true" and (not find(%Q@.groups .line input##{perm["permission"]}@).selected?))
        find(%Q@.groups .line input##{perm["permission"]}@).click()
    end
  end
  
  step 'I save the permissions'
end

When /^I add "([^"]*)" to grant user permissions$/ do |user|
  find(".users .line.add .button").click()
  find(".users .line.add input").set(user)
  wait_for_css_element(".ui-autocomplete li a")
  find(".ui-autocomplete li a").click()
end

Then /^I can choose from a set of labeled permissions presets instead of grant permissions explicitly$/ do
  find(".preset select").all("option").map(&:text).each do |preset_name|
    PermissionPreset.pluck(:name).include?(preset_name).should be_true
  end
end

When /^the resource is viewed by "([^"]*)"$/ do |user_name|
  step 'I am "%s"' % user_name
  visit media_resource_path(@resource)
end

Then /^he or she sees the following permissions:$/ do |table|
  step 'I open the permission lightbox'
  table.hashes.each do |entry|
    user = User.find_by_login(entry["user"].downcase) 
    permissions_container = find(".subject", :text => user.to_s).find(:xpath, './..').find(".permissions")
    permissions_container.find(".#{entry[:permission]} input").checked?.should be_true
  end
end

When /^I change the resource's public permissions as follows:$/ do |table|
  visit media_resource_path(@resource)
  step 'I open the permission lightbox'
  
  table.hashes.each do |perm| 
    if (perm["value"] == "false" and find(%Q@.public .line input##{perm["permission"]}@).selected?) \
      or (perm["value"] == "true" and (not find(%Q@.public .line input##{perm["permission"]}@).selected?))
        find(%Q@.public .line input##{perm["permission"]}@).click()
    end
  end
  
  step 'I save the permissions'
end

When /^I save the permissions$/ do 
  find("a.save").click()
  wait_until(10) { page.has_no_css?("#permissions") }
end

Then /^I cannot edit the following permissions any more:$/ do |table|
  visit media_resource_path(@resource)
  step 'I open the permission lightbox'
  
  table.hashes.each do |entry|
    sections = []
    sections << find("section.me")
    sections << find("section.users")
    sections << find("section.groups")
    sections.each do |section|
      section.all(".#{entry[:permission]}").each do |label|
        label.visible?.should be_false
      end
    end 
  end
end