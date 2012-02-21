Given /^a resource owned by "([^"]*)"$/ do |persona|
  owner = User.where("login=?",persona.downcase).first
  @resource = FactoryGirl.create :media_set, user: owner
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

Then /^"([^"]*)" can view the resource$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
