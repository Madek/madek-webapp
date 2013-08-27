Then /^Group "(.*?)" has "(.*?)" group\-permissions for my first media_entry$/ do |name, permission|
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @group = Group.where(name: name).first
  up = Grouppermission.where(media_resource_id: @my_first_media_entry.id).where(group_id: @group.id).first
  expect(up.send(permission)).to be_true
end

Then /^Group "(.*?)" has not "(.*?)" group\-permissions for my first media_entry$/ do |name, permission|
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @group = Group.where(name: name).first
  up = Grouppermission.where(media_resource_id: @my_first_media_entry.id).where(group_id: @group.id).first
  expect(up.send(permission)).to be_false
end
