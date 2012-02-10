When /^I visit my sets$/ do
  find(".head_menu .arrow").click()
  find(".item_line_set").click()
end

Then /^I only see my top level sets$/ do
  all_my_top_level_sets = @current_user.media_sets.top_level
  all(".item_box.set").size.should eql all_my_top_level_sets.size
  all_my_top_level_sets.each do |set|
    page.should have_content(set.title)
  end
end

Then /^I see all my sets$/ do
  all_my_sets = @current_user.media_sets
  all(".item_box.set").size.should eql all_my_sets.size
  all_my_sets.each do |set|
    page.should have_content(set.title)
  end
end

