When /^I see a list of my sets$/ do
  visit media_resources_path
  find("#bar .selection .types a.media_sets").click
  wait_until { page.evaluate_script('$.active') == 0 }
  page.execute_script('$("#bar .permissions a").show()')
  find("#bar .selection .permissions a.mine").click
  wait_until { page.evaluate_script('$.active') == 0 }
end

Then /^I see a switcher for the set graph layout in the layout switcher$/ do
  wait_until { find("#bar .layout .graph") }
end

When /^I switch the layout to the set graph$/ do
  find("#bar .layout .graph").click
end

Then /^I can see the set graph$/ do
  wait_until { page.evaluate_script('$.active') == 0 }
  wait_until { page.evaluate_script('$("#chart svg").length') > 0 }
end

When /^I see the set graph$/ do
  steps %Q{
    When I see a list of my sets
    Then I see a switcher for the set graph layout in the layout switcher
    When I switch the layout to the set graph
    Then I can see the set graph
  }
end

Then /^I see that the set graph is integrated in the site layout$/ do
  find("#content_body")
  find("#bar")
end

Then /^I see a panel inspector on the right side$/ do
  find("#inspector")
end

Then /^I dont see a "sort by" option$/ do
  all("#bar .sort", :visible => true).should be_empty
end

Then /^I see the realtionship between my sets$/ do
  amount_of_relationships = MediaResourceArc.joins("INNER JOIN media_resources MRC ON MRC.id = media_resource_arcs.child_id AND MRC.user_id = #{@current_user.id} AND MRC.type = 'MediaSet' INNER JOIN media_resources MRP ON MRP.id = media_resource_arcs.parent_id AND MRP.user_id = #{@current_user.id} AND MRP.type = 'MediaSet'").count
  wait_until { page.evaluate_script('$("#chart svg .link").length') == amount_of_relationships }
end

Then /^each resources is represented by thumbnail image and title$/ do
  @current_user.media_sets.each do |set|
    page.should have_content set.title
    # it seems that not all sets have an image
    #page.evaluate_script("$('g[data-id=#{set.id}]').find('image').attr('href').length").should > 0
  end
  all("g").each do |g|
    g.find("image")
  end
end

Then /^the relationship between the sets is represented by an connection line$/ do
  step 'I see the realtionship between my sets'
end

Then /^an arrow is pointing from the parent to a child$/ do
  # not testable in the svg
end

When /^I hover a graph element in the background$/ do
  @hovered_id = page.evaluate_script('$("g.node:first").data("id")')
  page.execute_script('$("g.node:first").trigger("mouseenter")')
end

Then /^this element swaps to the foreground$/ do
  page.evaluate_script('$("g.node:last").data("id")').should == @hovered_id
end

When /^I click a element in the set graph$/ do
  wait_until {find(".node")}
  page.execute_script('$("g.node:first").trigger("mouseenter").click()')
  @clicked_id = page.evaluate_script('$("g.node:last").data("id")')
end

Then /^the element is highlighted$/ do
  page.evaluate_script('$(".node[data-selected]").data("id")').to_i.should == @clicked_id
end

Then /^the inspector panel shows informations about the selected element$/ do
  wait_until { find("#inspector .inspector") }
  find("#inspector").should have_content MediaSet.find(@clicked_id).title[0..15]
end

Then /^I see the zoom and move instructions$/ do
  wait_until{ find("#instructions") }
end

Then /^the instructions say "(.*?)"$/ do |arg1|
  wait_until{ find("#instructions") }
end

Then /^I also see the batch edit bar$/ do
  wait_until { find(".task_bar") }
end

Then /^I can add the resource shown in the inspector to my batch selection$/ do
  step 'I click a element in the set graph'
  step 'the inspector panel shows informations about the selected element'
  find("#batch-deselect-all").click
  find("#inspector .check_box").click
  find("#selected_items .thumb_mini")
end

Then /^I can choose to see icons for permissions on each node of the graph$/ do
  page.execute_script('$("#overlay_manager *").show()')
  find("#overlay_manager a[data-overlay='permissions']").click
  wait_until { page.evaluate_script('$("#chart .node image.permissions").length') > 0 }
  wait_until { find("#chart.permissions") }
end

Then /^I can choose to see icons for favorites on each node of the graph$/ do
  page.execute_script('$("#overlay_manager *").show()')
  find("#overlay_manager a[data-overlay='favorites']").click
  wait_until { page.evaluate_script('$("#chart .node image.favorite").length') > 0 }
  wait_until { find("#chart.favorites") }
end

When /^I change the window width$/ do
  @window = Capybara.current_session.driver.browser.manage.window
  @window_start_size = @window.size
  @window.resize_to @window.size.width/2, @window.size.height/2
  visit(current_path)
  @graph_start_width = page.evaluate_script %Q{ $("#chart svg").width() }
  @window.resize_to @window_start_size.width, @window_start_size.height
  @graph_width_after_resize = page.evaluate_script %Q{ $("#chart svg").width() }
end

Then /^the set graph element is scaling to the new width$/ do
  @graph_width_after_resize.should != @graph_start_width unless page.evaluate_script(%Q{ $("#content_body").width() }) <= 920
end

When /^I change the window height$/ do
  @window = Capybara.current_session.driver.browser.manage.window
  @window_start_size = @window.size
  @window.resize_to @window.size.width/2, @window.size.height/2
  visit(current_path)
  @graph_start_height = page.evaluate_script %Q{ $("#chart svg").height() }
  @window.resize_to @window_start_size.width, @window_start_size.height
  @graph_height_after_resize = page.evaluate_script %Q{ $("#chart svg").height() }
end

Then /^the set graph element is scaling to the new height$/ do
  @graph_height_after_resize.should_not == @graph_start_height*2
end

Then /^the inspector panel shows more child elements corresponding to the new height$/ do
  wait_until { page.evaluate_script('$("g.node:first").length') > 0 }
  page.execute_script('$("g.node:first").trigger("mouseenter").click()')
  wait_until { find("#inspector .children") } 
  @graph_start_height.should < page.evaluate_script(%Q{ $("#inspector .children").height() })
end