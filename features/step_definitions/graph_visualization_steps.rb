# encoding: utf-8
Then /^I can see my relations for that resource[s]*$/ do
  nodes = 
    if @media_set
      #MediaResource.descendants_and_set(@media_set, MediaResource.accessible_by_user(@current_user))
      MediaResource.connected_resources(@media_set, @current_user.media_resources)
    elsif @media_entry
      MediaResource.connected_resources(@media_entry, @current_user.media_resources)
    else
      MediaResource.filter(@current_user, @filter) 
    end
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last
  wait_until { !current_url.match(/http:\/\//).nil? }
  env = Rack::MockRequest.env_for(current_url)
  request = Rack::Request.new(env)
  visit url_for Rails.application.routes.recognize_path(current_url).merge({:insert_to_dom => "true", :only_path => true}).merge(request.params)
  # nodes
  node_data = JSON.parse(find("#graph-data")[:"data-nodes"])
  node_data.map{|n| n["id"]}.sort.should == nodes.map(&:id).sort
  nodes.each{|node| find(".node[data-resource-id='#{node.id}']")}
  # arcs
  arcs = MediaResourceArc.connecting nodes
  arc_data = JSON.parse(find("#graph-data")[:"data-arcs"])
  arcs.each{|arc| arc_data.any?{|a| a["child_id"] == arc.child_id and a["parent_id"] == arc.parent_id}.should be_true}
  arcs.each{|arc| find(".arc[parent_id='#{arc.parent_id}'][child_id='#{arc.child_id}']")}
end

When /^I open one of my media entries that is child of a set that I can see$/ do
  @media_entry =@current_user.media_entries.detect{|me| me.parents.accessible_by_user(@current_user, :edit).size > 0}
  visit media_resource_path @media_entry
end

When /^I open one of my sets that has children and parents$/ do
  @media_set = MediaSet.find_by_id 22   
  visit media_resource_path @media_set
end

When /^I see a filtered list of resources where at least one element has arcs$/ do
  me = MediaEntry.accessible_by_user(@current_user).detect do |me|
    me.meta_data.where(:type => "MetaDatumKeywords").size > 0 and
    me.parents.accessible_by_user(@current_user).size > 0
  end
  @filter = {:meta_data => {:keywords => {:ids => [me.meta_data.where(:type => "MetaDatumKeywords").last.value.first.meta_term_id]}}}
  visit media_resources_path(@filter)
end

Given /^There are no persisted visualizations$/ do
  Visualization.delete_all
end

When /^I a see the graph of the resource "(.*?)"$/ do |resource|
    visit "/visualization/#{resource}"
end

When /^I get rid of the anoying browser warning$/ do
  find("#not_supported_warning button").click()
end


Then /^the label option "(.*?)" is selected$/ do |option|
  expect(find("form select.show_labels option[value='#{option}']").selected?).to be_true
end

Given /^I don't use Chrome or Safari$/ do
  expect(page.evaluate_script("BrowserDetection.name()")).not_to eq("Chrome")
  expect(page.evaluate_script("BrowserDetection.name()")).not_to eq("Safari")
end

When /^I open the visualization with the hash\-tag test_noupdate_positions$/ do
  visit "/visualization/my_media_resources#test_noupdate_positions"
end

Then /^I see the graph after it has finished layouting\/computing$/ do
  wait_until(5){all('#loading',visible: true).size > 0}
  wait_until(10){all('#loading',visible: true).size == 0}
end

Then /^I don't see "(.*?)"$/ do |arg1|
  expect(page.text[arg1]).not_to be
end


When /^I visit the visualization of "(.*?)"$/ do |arg1|
  visit "/visualization/#{arg1}"
end

When /^I inspect a media set node more closely$/ do
  @media_resource= @current_user.media_sets.first
  page.execute_script("Test.Visualization.mouse_enter_set(#{@media_resource.id})")
end

When /^I inspect a media entry node more closely$/ do
  @media_resource= @current_user.media_entries.first
  page.execute_script("Test.Visualization.mouse_enter_set(#{@media_resource.id})")
end

When /^The visualization test test_noupdate_positions is running$/ do
  wait_until(5){ all("#test_noupdate_positions_running").size > 0}
end

Then /^I see a popup$/ do
  expect(@popup = find(".ui-tooltip-content")).to be
end

Then /^I see the title of that resource$/ do
 expect(@popup.find("h2").text).to eq(@media_resource.title)
end

Then /^I see the permission icon for that resource$/ do
  # it suffices to test if there is an icon inside ui-thumbnail-privacy
  expect{ @popup.find(".ui-thumbnail-privacy i") }.not_to raise_error
end

Then /^I see the favorite status for that resource$/ do
  expect{@popup.find(".favorite_info i")}.not_to raise_error
end

Then /^I see the number of children devided by media entry and media set$/ do
  expect(@popup.find(".n_media_sets").text.to_i).to eq(@media_resource.child_media_resources.media_sets.size)
  expect(@popup.find(".n_media_entries").text.to_i).to eq(@media_resource.child_media_resources.media_entries.size)
end

Then /^I dont see any number of children and parents$/ do
  expect(@popup.all(".media_entry.icon").size).to eq(0)
  expect(@popup.all(".media_set.icon").size).to eq(0)
end

Then /^I see the links to the resource, \(my\-\)descendants, and \(my\)components$/ do
  expect{@popup.find("a#link_for_resource",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_component_with",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_my_component_with",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_my_descendants_of",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_descendants_of",visible: true)}.not_to raise_error
end

Then /^I see the links to the resource \(my\)components$/ do
  expect{@popup.find("a#link_for_component_with",visible: true)}.not_to raise_error
  expect{@popup.find("a#link_for_my_component_with",visible: true)}.not_to raise_error
end

Then /^I don't see the links to the resource \(my\)descendants$/ do
  expect(@popup.all("a#link_for_my_descendants_of",visible: true)).to be_empty
  expect(@popup.all("a#link_for_descendants_of",visible: true)).to be_empty
end

When /^I a see a graph$/ do
  visit "/visualization/my_media_resources"
end

Then /^I see a title$/ do
  (expect find("#title").text.size).to be > 0
end

When /^I visualize the filter "(.*?)"$/ do |filter|
  case filter
  when "Meine Sets"
    visit "/visualization/filtered_resources?type=media_sets&user_id=#{@current_user.id}"
  when "Meine Inhalte"
    visit "/visualization/filtered_resources?user_id=#{@current_user.id}"
  when "Mir anvertraute Inhalte"
    visit "/visualization/filtered_resources?not_by_user_id=#{@current_user.id}&public=false&type=all"
  when "Meine Favoriten"
    visit "/visualization/filtered_resources?favorites=true"
  else
    raise "implement this case"
  end
end

Then /^I see the title "(.*?)"$/ do |subtitle|
  (expect find("#title")).to have_content subtitle
end

When /^I visualize the filter Suchergebnisse für "(.*?)"$/ do |search|
  visit  "/visualization/filtered_resources?not_by_user_id=2&public=true&search=#{search}"
end

Then /^I see the title Suchergebnisse für "(.*?)"$/ do |search|
  (expect find("#title")).to have_content search
end

When /^I visualize the descendants of a Set$/ do
  @set = MediaSet.find(17)
  visit "/visualization/descendants_of/#{@set.id}"
end

Then /^I see the originating set beeing highlighted$/ do
  wait_until{all("#resource-#{@set.id} .origin").size  > 0 }
end

Then /^I see the title of the set as graph\-title$/ do
  (expect find("#title")).to have_content @set.title
end

When /^I visualize the component of a Entry$/ do
  @entry = MediaResource.find(21)
  visit "/visualization/component_with/#{@entry.id}"
end

Then /^I see the originating entry beeing highlighted$/ do
  (expect all("#resource-#{@entry.id} .origin")).not_to be_empty
end

Then /^I see the title of the entry as graph\-title$/ do
  (expect find("#title")).to have_content @entry.title
end

Then /^I see by default exactly the labels of the sets that have children in the current visualization$/ do
  all(".node:not([data-size='0'])").each do |el|
    expect{el.find(".node_label_title",visible: true)}.not_to raise_error
  end
  all(".node[data-size='0']").each do |el|
    jq =  " $('.node[id=#{el['id']}]').find('.node_label:visible').length "
    (expect page.evaluate_script(jq)).to be_zero
  end
end

When /^I select "(.*?)" of the label select options$/ do |value|
  find(".control_panel").click()
  find("#show_labels").select(value)
end

Then /^I see that all labels are show$/ do
  all(".node").each do |el|
    expect{el.find(".node_label_title",visible: true)}.not_to raise_error
  end
end


Then /^I see that none labels are show$/ do
  all(".node").each do |el|
    jq =  " $('.node[id=#{el['id']}]').find('.node_label:visible').length "
    (expect page.evaluate_script(jq)).to be_zero
  end
end
