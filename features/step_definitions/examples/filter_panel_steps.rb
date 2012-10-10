When /^I look at one of these pages, then I can use the filter panel, but its not open initially:$/ do |table|
  table.hashes.each do |hash|
    step "I go to #{hash[:page_type]}"
    step 'I open the filter panel'
    wait_until {find("#filter_area.open")}
  end
end

When /^I open the filter panel$/ do
  wait_until {find("#filter_area .filter.icon")}
  unless find("#filter_area")["class"].match "open"
    find("#filter_area .filter.icon").click
    wait_until {find("#filter_area.open")}
  end
end

When /^I look at one of these pages, then the filter panel is already expanded:$/ do |table|
  table.hashes.each do |hash|
    step "I go to #{hash[:page_type]}"
    step 'I open the filter panel'
  end
end

Given /^a list contains resources that have values in a meta key of type "(.*?)"$/ do |type|
  step 'I go to public content'
  step 'I open the filter panel'
  meta_key = case type
    when "Keywords"
      MetaKey.where(:meta_datum_object_type => "MetaDatumKeywords").first
  end
  all(".context > h3").each {|context| context.click}
  @key = find(".key[data-key_name='#{meta_key.label}']")
end

Then /^I can filter by the values for that particular key$/ do
  @key.find("h3").click
  @term = @key.find(".term")
  @term.click  
  wait_until {all(".loading", :visible=>true).size == 0}
  wait_until {all("#results .page .item_box").size > 0}
  all("#results .page .item_box").each do |item|
    mr = MediaResource.find item["data-id"].to_i
    mr.meta_data.map(&:to_s).any?{|md| md.match @term.text.gsub(/\n.*/, "")}.should be_true
  end
end

When /^I select a value to filter by$/ do
  step 'I go to public content'
  step 'I open the filter panel'
  all(".context > h3").each {|context| context.click}
  key = all(".key").last
  key.find("h3").click unless key["class"].match "open"
  @selected_term = key.find(".term")
  @selected_term.click
end

Then /^I see all the values that can be filtered or not filtered by$/ do
  all(".block").each_with_index do |block, i|
    block = all(".block")[i]
    block.find("h3").click unless block["class"].match "open"
    block.all(".term").each_with_index do |term, i|
      term = block.all(".term")[i]
      if term.all(".count").size > 0
        if term.find(".count").text.to_i > 0
          term.find("input")["disabled"].should be_nil
        else
          term.find("input")["disabled"].should == "true"
        end
      else
        term.find("input")["disabled"].should be_nil
      end
    end
  end
end

When /^I deselect the value$/ do
  block = all(".block").last
  block.find("h3").click unless block["class"].match "open"
  term = block.find(".term")
  term.find("input").checked?.should be_true
  term.find("input").click
  wait_until{all(".loading", :visible => true).size == 0}
end

Then /^none of the values are deactivated$/ do
  all(".block").each_with_index do |block, i|
    block = all(".block")[i]
    block.find("h3").click unless block["class"].match "open"
    block.all(".term").each_with_index do |term, i|
      term = block.all(".term")[i]
      term.find("input")["disabled"].should be_nil
    end
  end
end

Given /^a list of resources$/ do
  step 'I go to public content'
  @listOfResources = MediaResource.filter(@current_user, {:public => "true"})
end

When /^the list contains images$/ do
  @listOfResources.map(&:media_file).
    select{|mf| not mf.nil?}.map(&:extension).
    select{|ext| ext.match /jpg|jepg|png|tiff/}.
    size.should > 0
end


When /^I see the filter panel$/ do
  step 'I open the filter panel'
end

Then /^I see a list of MetaKeys the resources have values for$/ do
  all(".block").each_with_index do |block, i|
    block = all(".block")[i]
    block.find("h3").click unless block["class"].match "open"
    block.all(".term").each_with_index do |term, i|
      term = block.all(".term")[i]
      any = @listOfResources.any? do |mr|
        mr.meta_data.map(&:to_s).any?{|md| md.match term.text.gsub(/\n.*/, "")}
      end
      
      any.should be_true
    end
  end
end

Given /^I see a filtered list of resources$/ do
  meta_term_id = MediaResource.where(:view => true).flat_map{|x| x.meta_data.get("keywords") }.flat_map(&:value).first.try(:meta_term_id)
  filter = {:public => "true", :meta_data => {:keywords => {:ids => [meta_term_id]}}}
  visit media_resources_path(filter)
  step 'I open the filter panel'
  count = MediaResource.filter(@current_user, filter).count
  wait_until { find("#results .pagination", :text => /#{count} Resultate/) }
end

Then /^I see the match count for each value whose filter type is "(.*?)" and the values are sorted by match counts$/ do |arg1|
  all(:xpath, "//div[contains(@class, 'block')][@data-filter_type='#{arg1}']").each do |block|
    block.find("h3").click unless block["class"].match "open"
    block.all(".term").each_with_index do |term, i|
      #??# term = block.all(".term")[i]
      next_term = block.all(".term")[i+1] if i<block.all(".term").size-1 
      if next_term
        term.find(".count").text.to_i.should >= next_term.find(".count").text.to_i
      end
    end
  end
end

Then /^I do not see the match count for each value whose filter type is "(.*?)"$/ do |arg1|
  all(:xpath, "//div[contains(@class, 'block')][@data-filter_type='#{arg1}']").each do |block, i|
    block.find("h3").click unless block["class"].match "open"
    block.all(".term").each do |term|
      term.all(".count").size.should be_empty
    end
  end
end

When /^I open a set that has children$/ do
  @media_set = MediaSet.filter(@current_user).detect{|ms| ms.child_media_resources.filter(@current_user).media_entries.any?{|me| me.meta_data.where(:type => "MetaDatumKeywords").exists?} }
  visit media_resource_path @media_set
end

Then /^I can expand the filter panel$/ do
  step 'I open the filter panel'
end

Then /^I see a list of MetaKeys$/ do
  all(".context > h3").each {|context| context.click}
  @key = find("#filter_area").find(:xpath, "//div[@data-filter_type='meta_data']").find(".key")
end

Then /^I can open a particular MetaKey$/ do
  @key.find("h3").click
end

Then /^I can filter by the values of that key$/ do
  @term = @key.find(".term")
  @term.click  
  wait_until {all(".loading", :visible=>true).size == 0}
  wait_until {find("#results .page .item_box")}
  wait_until {find("#filter_area .key")}
  all("#results .page .item_box").each do |item|
    mr = MediaResource.find item["data-id"].to_i
    mr.meta_data.map(&:to_s).any?{|md| md.match @term.text.gsub(/\n.*/, "")}.should be_true
  end
end

When /^I click "(.*?)"$/ do |arg1|
  find("#filter_area .reset > h4").click
end

Then /^the list is not filtered anymore$/ do
  count = MediaResource.where(:view => true).count
  wait_until { find("#results .pagination", :text => /#{count} Resultate/) }
end

When /^I expand the root block "(.*?)"$/ do |arg1|
  find("#filter_area .#{arg1} >*:first-child").click()
end

When /^I expand the sub\-block "(.*?)" of the root block "(.*?)"$/ do |sub, root|
   find("#filter_area .#{root} *[data-key_name='#{sub}'] >*:first-child").click()
end

Then /^I can filter letting me choose "(.*?)" in the sub\-block "(.*?)" of the root block "(.*?)"$/ do |type, sub, root|
  all("#filter_area .#{root} *[data-key_name='#{sub}'] .text").map(&:text).should include(type)
  find("#filter_area .#{root} *[data-key_name='#{sub}'] input[value='#{type}']+.text").click()
end

When /^I collapse its parent key$/ do
  @selected_term.find(:xpath, "./../..[contains(@class, 'key')]/h3").click
end

Then /^I collapse its parent context$/ do
  @selected_term.find(:xpath, "./../../..[contains(@class, 'context')]/h3").click
end

Then /^all selected nested terms do not disappear$/ do
  wait_until {(all(".term.selected", :visible => true).size - all(".term.selected", :visible => false).size).should == 0}
  @selected_term.reload[:class].include?("selected")
end


