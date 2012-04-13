When /^I look at one of these pages then I can see the action bar:$/ do |table|
  table.hashes.each do |row|
    step 'I go to %s' % row[:page_type]
    wait_until { find("#bar") }
  end
end

When /^I see the action bar$/ do
  step 'I go to public content'
end

Then /^I can choose between showing (.*)$/ do |type|
  wait_until { find("#bar") }
  case type
    when "only sets"
      find("#bar .selection .types .media_sets").click
      wait_until { find(".item_box") }
      all(".item_box:not(.set)").size.should == 0
    when "only media entries"
      find("#bar .selection .types .media_entries").click
      wait_until { find(".item_box") }
      all(".item_box.set").size.should == 0
    when "media entries and sets"
      find("#bar .selection .types .all").click
      wait_until { find(".item_box") }
      all(".item_box.set").size.should_not == 0
      all(".item_box:not(.set)").size.should_not == 0
  end
end

Then /^I can filter content (.*)$/ do |filter|
  wait_until { find("#bar") }
  page.execute_script("$('#bar .permissions a').show()")
  case filter
    when "by any permissions"
      find("#bar .selection .permissions .all").click
      wait_until { find("#bar") }
      find("#bar .permissions .all.active")
    when "by my content"
      find("#bar .selection .permissions .mine").click
      wait_until { find("#bar") }
      find("#bar .permissions .mine.active")
    when "assigned to me"
      find("#bar .selection .permissions .entrusted").click
      wait_until { find("#bar") }
      find("#bar .permissions .entrusted.active")
    when "content that is public"
      find("#bar .selection .permissions .public").click
      wait_until { find("#bar") }
      find("#bar .permissions .public.active")
  end  
end

Then /^I can sort by (.*)$/ do |sort_by|
  wait_until { find("#bar") }
  page.execute_script("$('#bar .sort a').show()")
  case sort_by
    when "created at"
      find("#bar .sort .created_at").click
      wait_until { find("#bar") }
      find("#bar .sort .created_at.active")
    when "updated at"
      find("#bar .sort .updated_at").click
      wait_until { find("#bar") }
      find("#bar .sort .updated_at.active")
  end
end

When /^I can switch the layout of the results to the (.*) view$/ do |layout|
  wait_until { find("#bar") }
  case layout
    when "grid"
      find("#bar .layout .grid").click
      wait_until { find("#bar") }
      find("#bar .layout .grid.active")
  end
end

When /^I change any of the settings in the bar then i am forwarded to a different page url$/ do
  step 'I see the action bar'
  last_url = current_url
  step 'I can choose between showing only sets'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can choose between showing only media entries'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can choose between showing media entries and sets'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can filter content by any permissions'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can filter content by my content'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can filter content assigned to me'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can filter content that is public'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can sort by created at'
  last_url.should_not be current_url
  last_url = current_url
  step 'I can sort by updated at'
  last_url.should_not be current_url
  last_url = current_url
end

Then /^the counter is formatted as "([^"]*)"$/ do |string|
  string = "/#{string}/"
  string.gsub!(/[N,M]/,'\d')
  find("*", :text => eval(string))
end
