Then /^I can see the relations for that resource[s]*$/ do
  if @media_set
    nodes = MediaResource.descendants_and_set(@media_set, MediaResource.accessible_by_user(@current_user))
  elsif @media_entry
    nodes = MediaResource.connected_resources(@media_entry, MediaResource.accessible_by_user(@current_user))
  else
    nodes = MediaResource.filter(@current_user, @filter) 
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

When /^I open a media entry that is child of a set that I can see$/ do
  @media_entry = MediaEntry.accessible_by_user(@current_user, :edit).detect{|me| me.parents.accessible_by_user(@current_user, :edit).size > 0}
  visit media_resource_path @media_entry
end

When /^I open a set that has children and parents$/ do
  @media_set = MediaSet.accessible_by_user(@current_user, :edit).detect{|ms| ms.parents.accessible_by_user(@current_user, :edit).size > 0 and ms.child_media_resources.accessible_by_user(@current_user, :edit).size > 0}
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


