# -*- encoding : utf-8 -*-
#
 
Then /^I make the group name empty$/ do
  find("#show-edit-name").click
  find("input#group-name").set ""
end

Then /^I move all MetaData from that person to another person$/ do
  @meta_data_transfer_link.click()
  find("input#id_receiver").set(Person.reorder(:created_at,:id).first.id)
  step "I submit"
end

When /^I move all resources from that keyword to another keyword$/ do
  keyword_receiver = KeywordTerm.with_count.order("keywords_count DESC").last
  @keyword_transfer_link.click
  find("input#id_receiver").set(keyword_receiver.id)
  step "I submit"
end

Then /^I move all resources from that meta term to another meta term$/ do
  @resources_transfer_link.click()
  find("input#id_receiver").set(MetaTerm.reorder(:term,:id).first.id)
  step "I submit"
end

