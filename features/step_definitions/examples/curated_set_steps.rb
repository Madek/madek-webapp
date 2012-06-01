When /^I open a set that I can edit which has children$/ do
  @media_set = MediaSet.accessible_by_user(@current_user, :edit).detect{|x| x.out_arcs.size > 0}
  visit media_resource_path(@media_set)
end

Then /^I see the the option to edit the highlights for this set$/ do
  wait_until {find(".open_media_set_highlights_lightbox", :visible => true)}
end

Then /^I can select which children to highlight$/ do
  find(".open_media_set_highlights_lightbox").click
  wait_until(10){ all(".loading", :visible => true).size == 0 }
  wait_until(10){ all("#media_set_highlights_lightbox table.media_resources tr", :visible => true).size > 0 }
end

When /^I open a set that I can not edit which has children$/ do
  @media_set = (MediaSet.accessible_by_user(@current_user, :view) - MediaSet.accessible_by_user(@current_user, :edit)).detect{|x| x.out_arcs.size > 0}
  visit media_resource_path(@media_set)
end

Then /^I don't see the option to edit the highlights for this set$/ do
  all(".open_media_set_highlights_lightbox", :visible => true).size.should == 0
end

When /^I select a resource to be highlighted$/ do
  @highlight = @media_set.out_arcs.first.child
  find("table.media_resources tr", :text => @highlight.title).find(".selection input").click
  find("#media_set_highlights_lightbox .save").click
  wait_until(30){ all("#media_set_highlights_lightbox", :visible => true).size == 0 }
end

Then /^the resource is highlighted$/ do
  wait_until { find("#media_set_highlights .highlight", :text => @highlight.title) }
end

When /^I view a set with highlighted resources$/ do
  @media_set = MediaSet.accessible_by_user(@current_user, :edit).detect{|x| x.out_arcs.where(:highlight => true).size > 0}
  visit media_resource_path(@media_set)
end

Then /^I see the highlighted resources in bigger size than the other ones$/ do
  wait_until { find(".thumb_box") }
  @highlight = @media_set.out_arcs.where(:highlight => true).first.child
  find(".highlight", :text => @highlight.title)
  evaluate_script("$('.highlight:first img').width()").should > evaluate_script("$('.thumb_box:first img').width()") 
  evaluate_script("$('.highlight:first img').height()").should > evaluate_script("$('.thumb_box:first img').height()") 
end

Then /^I see the highlighted resources twice, once in the highlighted area, once in the "([^"]*)" list$/ do |arg1|
  find("#media_set_highlights .highlight", :text => @highlight.title)
  find("#results .item_box", :text => @highlight.title)
end