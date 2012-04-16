When /^I visit my sets$/ do
  find(".head_menu .arrow").click()
  find(".item_line_set").click()
end

Then /^I only see my top level sets$/ do
  all_my_top_level_sets = @current_user.media_sets.top_level
  wait_until { all(".item_box.set").size > 0 }
  all(".item_box.set").size.should eql all_my_top_level_sets.size
  all_my_top_level_sets.each do |set|
    page.should have_content(set.title)
  end
end

Then /^I see all my sets$/ do
  all_my_sets = @current_user.media_sets
  wait_until { all(".item_box.set").size > 0 }
  all(".item_box.set").size.should eql all_my_sets.size
  all_my_sets.each do |set|
    page.should have_content(set.title)
  end
end

When /^I switch the scope to all my top level sets$/ do
  page.execute_script("$('.scope_sets a').show()")
  find("#bar .scope_sets .top_level").click
  wait_until { find(".item_box.set") }
end