Then /^Petra has "(.*?)" user\-permission on the new media_entry with the tile "(.*?)"$/ do |permission, title|
  me = @new_media_entries.select{|me| me.title == title}.first
  userpermission = me.userpermissions.joins(:user).where("users.login = 'petra'").first
  expect(userpermission.send permission).to be_true
end
