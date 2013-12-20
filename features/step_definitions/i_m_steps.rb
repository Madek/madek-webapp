# -*- encoding : utf-8 -*-
#
 
Then /^I make the group name empty$/ do
  find("#show-edit-name").click
  find("input#group-name").set ""
end

Then /^I move all MetaData from that person to another person$/ do
  @meta_data_transfer_link.click()
  find("input#id_receiver").set(Person.reorder("created_at DESC").first.id)
  find("[type='submit']").click()
end


