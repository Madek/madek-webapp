Then /^I should see that all visible resources are in my batch bar$/ do
  visible_resources = all(".item_box", :visible => true)
  visible_resources.each do |item|
    puts item.text
  end
  batch_elements = all(".task_bar .thumb_mini")
  batch_elements.each do |item|
    puts item.text
  end
  visible_resources.size.should eql batch_elements.size
end

When /^I use batch's select all$/ do
  find("#batch-select-all").click()
  sleep 1.0
end