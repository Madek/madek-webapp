When /^(?:|I )open the "(.+)" set$/ do |title|
  id = nil
  MediaSet.all.each do |set|
    if set.title == title
      id = set.id
      break
    end
  end
  visit media_set_path(id)
end

When /^(?:|I )open the "(.+)" entry/ do |title|
  id = nil
  MediaEntry.all.each do |entry|
    if entry.title == title
      id = entry.id
      break
    end
  end
  visit media_entry_path(id)
end

When /^(?:|I )open the selection widget for this (.+)$/ do |type|
  case type
    when "set"
      sleep(2)
      wait_until { find("#set_actions .has-set-widget") }
      find("#set_actions .has-set-widget").click
    when "entry"
      sleep(2)
      wait_until { find("#detail-action-bar .has-set-widget") }
      find("#detail-action-bar .has-set-widget").click
    when "batchedit"
      sleep(2)
      wait_until { find(".task_bar .has-set-widget") }
      find(".task_bar .has-set-widget").click
    when "page"
      find(".has-set-widget").click
  end
  wait_for_css_element(".widget .list")
end

When /^(?:|I )select "(.+)" as parent set$/ do |label|
  label.gsub!(/\s/, "_")
  raise "#{label} is already selected so you can not select it again" if find("input##{label}").checked?
  wait_until(20) { find("input##{label}:not(selected)") }
  find("input##{label}:not(selected)").click
  raise "#{label} was not selected" unless find("input##{label}").checked?
end

When /^(?:|I )deselect "(.+)" as parent set$/ do |label|
  label.gsub!(/\s/, "_")
  raise "#{label} is not selected so you can not deselect it" unless find("input##{label}").checked?
  find("input##{label}").click
  raise "#{label} was not deselected" if find("input##{label}").checked?
end

When /^(?:|I )submit the selection widget$/ do
  wait_until(40){find(".widget .submit")}
  find(".widget .submit").click
  wait_until(40){ all(".widget", :visible => true).size == 0 }
end

When /^(?:|I )create a new set named "(.+)"$/ do |name|
  wait_until(15){ find(".widget .create_new a") }
  find(".widget .create_new a").click
  wait_until(15){ find("#create_name") }
  fill_in("create_name", :with => name)
  wait_until(15){ find(".widget .create_new .button") }
  find(".widget .create_new .button").click
  wait_until(15){ find(".widget .create_new a") }
end

When /^(?:|I )create a new set$/ do
  find(".widget .create_new a").click
  find(".widget .create_new div.button").click
  wait_for_css_element(".create_new a")
end

When /^(?:|I )should see the "(.+)" set inside the widget$/ do |name|
  find(".widget").should have_content(name)
end

When /^(?:|I )should not see the "(.+)" set inside the widget$/ do |name|
  find(".widget").should have_no_content(name)
end

When /^(?:|I )search for "(.+)"$/ do |search|
  fill_in("widget_search", :with => search)
end

