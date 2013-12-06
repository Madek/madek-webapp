# -*- encoding : utf-8 -*-


Then /^I delete a group where I'm not the only remaining member$/ do
  @group = @current_user.groups.joins("INNER JOIN groups_users AS gu2 ON groups.id = gu2.group_id").group("groups.id, gu2.group_id").having("count(gu2.group_id) > 1").first
  find(".ui-workgroups tr[data-id='#{@group.id}'] .button.delete-workgroup").click
end

Then /^I delete all existing authors$/ do
  all("fieldset[data-meta-key='author'] ul.multi-select-holder li a",visible:true).each{|e| e.click}
end

When /^I delete the import "(.*?)"$/ do |text|
  find("ul#mei_filelist li",text: text).find("a.delete_mei").click
end

Then /^I delete the dropbox import "(.*?)"$/ do |text|
  find("ul#dropbox_filelist li",text: text).find("a.delete_dropbox_file").click
end

Then /^I delete a user$/ do
  all("a",text: "Delete").first.click
end

Then /^I delete that group$/ do
  find(".ui-workgroups tr[data-id='#{@group.id}'] .button.delete-workgroup").click
  step 'I wait for the dialog to appear'
  step 'I click the primary action of this dialog'
  step 'I wait for the dialog to disappear'
end

Then /^I delete the person$/ do
  @delete_link.click
end

Then /^I disconnect any contexts from that set$/ do
  @individual_contexts.each do |context|
    find("input[value='#{context.id}']").click
  end
  step 'I submit'
end

Then /^I don't provide a name$/ do
  find("input[name='name']").set ""
end

Then /^I don't use Chrome or Safari$/ do
  expect(page.evaluate_script("BrowserDetection.name()")).not_to eq("Chrome")
  expect(page.evaluate_script("BrowserDetection.name()")).not_to eq("Safari")
end

Then /^I don't see "(.*?)"$/ do |arg1|
  expect(page.text[arg1]).not_to be
end

Then /^I dont see any number of children and parents$/ do
  expect(@popup.all(".media_entry.icon").size).to eq(0)
  expect(@popup.all(".media_set.icon").size).to eq(0)
end

Then /^I don't see groups with "(.*?)" type$/ do |group_type|
  all( "table tbody tr" ).each do |row|
    expect( row ).not_to have_content(group_type)
  end
end

Then /^I don't see the links to the resource \(my\)descendants$/ do
  expect(@popup.all("a#link_for_my_descendants_of",visible: true)).to be_empty
  expect(@popup.all("a#link_for_descendants_of",visible: true)).to be_empty
end
