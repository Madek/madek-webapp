Then /^I should see that all visible resources are in my batch bar$/ do
  visible_resources = all(".item_box", :visible => true)
  batch_elements = all(".task_bar .thumb_mini")
  visible_resources.size.should eql batch_elements.size
end

When /^I use batch's select all$/ do
  find("#batch-select-all").click()
  sleep 1.0
end

When /^I use batch's deselect all$/ do
  wait_until {find("#batch-deselect-all")}
  sleep 1.0
  find("#batch-deselect-all").click()
  sleep 1.0
end

Given /^two media resources with (.*?) value for the meta datum type (.*?)$/ do |value, type|
  current_meta_data_index = 0
  begin
    @one = MediaEntry.accessible_by_user(@current_user, :edit).detect {|me| 
      meta_data = me.meta_data.where(:type => type)
      if current_meta_data_index <= meta_data.size and not meta_data.empty?
        @meta_key = meta_data[current_meta_data_index].meta_key
      else
        false
      end
    }
    ones_value = @one.meta_data.where(:meta_key_id => @meta_key.id).first.value
    @another = MediaEntry.accessible_by_user(@current_user, :edit).where(MediaResource.arel_table[:id].not_eq(@one.id)).detect {|me|
      meta_data = me.meta_data.where(:meta_key_id => @meta_key.id)
      unless meta_data.empty?
        same_value = meta_data.first.same_value? ones_value
        if value == "same"
          same_value
        elsif value == "different"
          not same_value
        end
      else
        false
      end
    }
    current_meta_data_index += 1
  end while not (@one and @another)
end

When /^I edit two MediaEntries meta data that have different values for a MetaData with type "(.*?)"$/ do |type|
  step "two media resources with different value for the meta datum type #{type}"
  step 'I batch edit those two media resources'
end

When /^I edit two MediaEntries meta data that have the same values for a MetaData with type "(.*?)"$/ do |type|
  step "two media resources with same value for the meta datum type #{type}"  
  step 'I batch edit those two media resources'
end

When /^I batch edit those two media resources$/ do
  visit media_resources_path
  wait_until { all(".thumb_box").size > 0 }

  find("#batch-deselect-all input").click

  one_element = find_media_resource_by_id @one.id
  another_element = find_media_resource_by_id @another.id

  step 'all the entries controls become visible'
  
  one_element.find(".check_box").click
  another_element.find(".check_box").click

  find("#batch-edit input").click
end

Then /^I should see that this meta data field has (.*?) value[s]*$/ do |value|
  while(all("ul[data-meta_key='#{@meta_key.label.gsub(/\s/, "_")}']", :visible => true).empty?)
    switch_to_next_meta_data_context
  end

  if value == "same"
    find("ul[data-meta_key='#{@meta_key.label.gsub(/\s/, "_")}']").all(".different_values").size.should == 0
  else
    find("ul[data-meta_key='#{@meta_key.label.gsub(/\s/, "_")}']").find(".different_values")
  end
end