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

Then /^"(.*?)" has not yet accepted the usage terms$/ do |login|
  User.find_by_login(login).update_attributes!(usage_terms_accepted_at: nil)
end

Then (/^in the "(.*?)" dropdown "(.*?)" should be selected$/) do |element, option|
  expect(page.evaluate_script("$('select.#{element}').val()")).to eq option
end
