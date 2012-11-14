When /^I see a filtered list of resources with more then one page$/ do
  visit media_resources_path(:search => "")
  find("#filter_area .filter.icon").click
  @total_count = find(".pagination").text[/\d+/].to_i
  all(".context > h3").each {|c| c.click}
  all(".key > h3").each {|k| k.click}
  all("#filter_area .term").each do |term|
    term_count = term.find(".count").text.to_i
    if  term_count > 36 and term_count < @total_count
      @selected_term = term
      break
    end
  end
  @selected_term.click
  wait_until { all(".loading").size == 0 }
  @current_filter = page.evaluate_script('$("section.media_resources.index").data("controller").filter_panel.current_filter')
  @total_count = find(".pagination").text[/\d+/].to_i
end

Then /^I can paginate to see the following pages which are also filtered$/ do
  find(".page[data-page='2']").click
  wait_until{ all(".page[data-page='2']").size == 0 }
  wait_until{ find(".page", :text => /Seite\s2\s/).all(".item_box[data-id]").size > 0 }
  @current_filter.should == page.evaluate_script('$("section.media_resources.index").data("controller").filter_panel.current_filter')
  all(".page")[1].find(".pagination").text[/\d+/].to_i.should == @total_count
end
