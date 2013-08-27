# -*- encoding : utf-8 -*-

Then /^User "(.*?)" has "(.*?)" user\-permissions for my first media_entry$/ do |login, permission|
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @user = User.where(login: login).first
  up = Userpermission.where(media_resource_id: @my_first_media_entry.id).where(user_id: @user.id).first
  expect(up.send(permission)).to be_true
end

Then /^User "(.*?)" has not "(.*?)" user\-permissions for my first media_entry$/ do |login, permission|
  @my_first_media_entry = @me.media_entries.reorder("created_at ASC").first
  @user = User.where(login: login).first
  up = Userpermission.where(media_resource_id: @my_first_media_entry.id).where(user_id: @user.id).first
  expect(up.send(permission)).to be_false
end

