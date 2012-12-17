
When /^I navigate to the admin\/people interface$/ do
  visit "/admin/people"  
end

Then /^for each person I see the id$/ do
  expect{find("th.id")}.not_to raise_error
end

Then /^I see the count of MetaData associated to each person$/ do
  wait_until{ all(".meta_data_count").size > 0 }
  expect( all(".meta_data_count").size).to be  > 0
end

When /^a person has some MetaData associated to it$/ do
  @person_with_meta_data = Person.find 7
  expect{ @meta_data_transfer_link = find("tr#person_#{@person_with_meta_data.id} a.transfer_meta_data_link")}.not_to raise_error
end

When /^I move all MetaData from that person to another person$/ do
  @meta_data_transfer_link.click()
  find("input#id_receiver").set(1)
  find("[type='submit']").click()
end

Then /^I am redirected to the admin people list$/ do
  expect(current_path).to eq "/admin/people"
end

Then /^the origin person has not meta_data to transfer$/ do
  expect{find("tr#person_#{@person_with_meta_data.id} .meta_data_count")}.to raise_error
end


When /^a person does not have any MetaData neither User associated to it$/ do
  @person_without_meta_data = Person.find 7
  ActiveRecord::Base.connection.execute "delete from meta_data_people where person_id = 7"
  visit(current_path)
  expect{  find("tr#person_#{@person_without_meta_data.id} .meta_data_count") }.to raise_error
end

Then /^I can delete that person$/ do
  expect{ @delete_link = find("tr#person_#{@person_without_meta_data.id} a",text: 'Delete')}.not_to raise_error
end

When /^I delete the person$/ do
  @delete_link.click
end

Then /^the person is deleted$/ do
  expect{find "tr#person_7"}.to raise_error
end

Then /^I can not delete that person$/ do
  expect{ find("tr#person_#{@person_without_meta_data.id} a",text: 'Delete')}.to raise_error
end
