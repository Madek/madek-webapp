Given /^a resource owned by "([^"]*)"$/ do |persona|
  owner = User.where("login=?",persona.downcase).first
  @resource = FactoryGirl.create :media_entry, user: owner
end

Given /^a resource$/ do
  owner = Factory :user
  @resource = FactoryGirl.create :media_entry, user: owner
end

Given /^a set owned by "([^"]*)"$/ do |persona|
  owner = User.where("login=?",persona.downcase).first
  @resource = FactoryGirl.create :media_set, user: owner
end

Given /^a set named "([^"]*)" owned by "([^"]*)"$/ do |title, persona|
  owner = User.where("login=?",persona.downcase).first
  @resource = Factory(:media_set,
                      user: owner, 
                      meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: title}})
end

Given /^a set named "([^"]*)"$/ do |title|
  owner = Factory :user
  @resource = Factory(:media_set,
                      user: owner, 
                      meta_data_attributes: {0 => {meta_key_id: MetaKey.find_by_label("title").id, value: title}})
end

Given /^the resource has the following permissions:$/ do |table|
  table.hashes.each do |hash|
    persona = hash[:user]
    permission = hash[:permission]
    bool_value = hash[:value] == "true"
    up = Userpermission.create media_resource: @resource, user:  User.where("login=?",persona.downcase).first
    up.update_attributes permission => bool_value
  end
end

Then /^"([^"]*)" can ([^"]*) the resource$/ do |user, permission|
  visit "/resources/#{@resource.id}/"
  open_permissions
  find(".me .line .permissions .#{permission} input").checked?
end

Then /^"([^"]*)" is the owner of the resource$/ do |user|
  visit "/resources/#{@resource.id}/"
  open_permissions
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
  visit resource_path(resource)
  
  if resource.is_a? MediaSet
    page.should have_css("#info_tab h3", :text => resource_title)
  elsif resource.is_a? MediaEntry
    page.should have_css("h2.title", :text => resource_title)
  end
end

Given /^I can not view "([^"]*)" by "([^"]*)"$/ do |resource_title, user_name|
  owner = User.where("login=?",user_name.downcase).first
  resource = MediaResource.find_by_title(resource_title).first
  visit resource_path(resource)
  
  URI.parse(current_url).path.should == root_path
end
