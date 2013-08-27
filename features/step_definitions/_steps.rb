Then /^"(.*?)" has no user\-permission for my first media_entry$/ do |login|
  expect(
    @me.media_entries.reorder("created_at ASC").first.userpermissions.joins(:user).where("users.login = ?",login).count 
  ).to eq 0
end

Then /^"(.*?)" has no group\-permission for my first media_entry$/ do |group_name|
  expect(
    @me.media_entries.reorder("created_at ASC").first.grouppermissions.joins(:group).where("groups.name= ?",group_name).count 
  ).to eq 0
end
