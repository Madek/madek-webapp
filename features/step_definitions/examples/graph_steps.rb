Then /^I can see the relations for that resource[s]*$/ do
  @resources = @media_set
  @resources ||= @media_entry
  @resources ||= MediaResource.filter(@current_user, @filter) 
  # nodes
  nodes = if @filter then @resources else MediaResource.connected_resources @resources end
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last
  node_data = page.evaluate_script("Visualization.nodes")
  node_data.map{|n| n["id"]}.sort.should == nodes.map(&:id).sort
  nodes.each{|node| find(".node[data-resource-id='#{node.id}']")}
  # arcs
  arcs = MediaResourceArc.connecting nodes
  arc_data = page.evaluate_script("Visualization.arcs")
  arcs.each{|arc| arc_data.any?{|a| a["child_id"] == arc.child_id and a["parent_id"] == arc.parent_id}.should be_true}
  arcs.each{|arc| find(".arc[parent_id='#{arc.parent_id}'][child_id='#{arc.child_id}']")}
  ###
  # TODO test that the layouter works !
  ###
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