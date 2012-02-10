Then /^I should see that all visible resources are in my batch bar$/ do
  visible_resources = all(".item_box", :visible => true)
  batch_elements = all(".task_bar .thumb_mini")
  visible_resources.size.should eql batch_elements.size
end

When /^I use batch's select all$/ do
  find("#batch-select-all").click()
  sleep 1.0
end