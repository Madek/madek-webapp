Then(/^I can see all resources$/) do
  expect(find("#resources_counter").text.to_i).to eq MediaResource.count
end

Then(/^I can see more resources than before$/) do
  expect(find("#resources_counter").text.to_i).to be > @resources_counter
end


Then(/^I see exactly the same number of resources as before$/) do
  expect(find("#resources_counter").text.to_i).to eq @resources_counter
end

Given(/^the resource with the id "(.*?)" has doesn't belong to me and has no other permissions$/) do |id|
  resource = MediaResource.find id
  expect(resource.user).not_to eq @me
  expect(resource.userpermissions.count).to eq 0
  expect(resource.grouppermissions.count).to eq 0
end


Given(/^the resource with the id "(.*?)" has no public view permission$/) do |id|
  MediaResource.find(id).update_attributes view: false
end


Then(/^I am the last editor of the media entry with the id "(.*?)"$/) do |id|
  expect(MediaEntry.find(id).editors.reorder("edit_sessions.created_at DESC").first).to be == @me
end


