# -*- encoding : utf-8 -*-

When /^I switch to the (.*?) view$/ do |layout|
  wait_until { find("#bar") }
  find("#bar .layout a[data-type=#{layout.downcase}]").click
end

Then /^each resource is represented as one row of data$/ do
  wait_until { find(".item_box") }
  page.evaluate_script('$(".item_box:first").width()').should > page.evaluate_script('$(".item_box:first").height()')
end

Then /^for each resource I see meta data from the "(.*?)" context$/ do |context|
  @inspected_resource = MediaResource.accessible_by_user(@current_user).last
  @inspected_resource_element = find(".item_box[data-id='#{@inspected_resource.id}']")
  @inspected_meta_data = @inspected_resource.meta_data.for_context(MetaContext.send(context), false)
  @inspected_meta_data.each do |meta_datum|
    @inspected_resource_element.should have_content meta_datum.to_s
  end
end

When /^I see a list of sets in list view$/ do
  visit media_resources_path(:type => "media_sets")
  wait_until { find("#bar .layout .icon[data-type='list']") }.click
end

Then /^for each resource I see a thumbnail image if it is available$/ do
  unless @inspected_resource_element[:class] =~ /set/
    @inspected_resource_element.find("img")
  end
end

When /^I see the "(.*?)" meta key of a set/ do |meta_key|
  step 'I see all meta data contexts'
  case meta_key
    when"children"
      wait_until { find("dt.child_media_resources") }
      @el = find("dt.child_media_resources").find(:xpath, "..")
    when "parents"
      wait_until { find("dt.parent_media_resources") }
      @el = find("dt.parent_media_resources").find(:xpath, "..")
  end
end


When /^I see a resource in a list view$/ do
  step 'I see a list of resources'
  step 'I switch to the list view'
  @inspected_resource = MediaResource.accessible_by_user(@current_user).last
  wait_until {find(".item_box[data-id='#{@inspected_resource.id}']")}
  @inspected_resource_element = find(".item_box[data-id='#{@inspected_resource.id}']")
end

Then /^the following actions are available for this resource:$/ do |table|
  @action_menu = @inspected_resource_element.find(".action_menu")
  table.hashes.each do |row|
    case row[:action]
      when "Als Favorit merken"
        @inspected_resource_element.find(".favorite_link")
      when "Zur Auswahl hinzufügen/entfernen"
        @inspected_resource_element.find(".check_box")
      when "Editieren" || "Löschen"
        @action_menu.should have_content row[:action] if @current_user.authorized?(:edit, @inspected_resource)
      when "Zugriffsberechtigungen lesen/bearbeite"
        @action_menu.should have_content row[:action]
      when "Zu Set hinzufügen/entfernen"
        @action_menu.should have_content row[:action]
      when "Erkunden nach vergleichbaren Medieneinträgen"
        @action_menu.should have_content row[:action] if @inspected_resource.meta_data.for_meta_terms.exists?
    end
  end
end

Then /^the resource's title is highlighted$/ do
  page.evaluate_script('$("dd.title.full").css("fontSize")').to_f.should > page.evaluate_script('$("dd:not(.title)").css("fontSize")').to_f
end

When /^I click the title$/ do
  find("dd.title.full").click
end

Then /^I'm redirected to the media resource's detail page$/ do
  wait_until { not current_url.match(/\d+$/).nil? }
end

Then /^I see the number and type of (.*)/ do |arg|
  @el.find("dd.full")[:title].match(/\d MediaSets/).should be_true
  @el.find("dd.full")[:title].match(/\d MediaEntries/).should be_true if @el.find("dt")[:class] == "child_media_resources"
end

Then /^the type is shown through an icon$/ do
  @el.find(".media_set.icon")
  @el.find(".media_entry.icon") if @el.find("dt")[:class] == "child_media_resources"
end

When /^I see all meta data contexts/ do
  step 'I wait for the AJAX magic to happen'
  page.execute_script('$(".meta_data .context").show()')
  find("#bar .layout a[data-type=grid]").click
  find("#bar .layout a[data-type=list]").click
  page.execute_script('$(".meta_data .context").show();$(".meta_data .context").css("display", "table-cell !important")')
  step 'I wait for the AJAX magic to happen'
  wait_until { find(".item_box .meta_data").reload.all(".context").size == find(".item_box .meta_data").reload.all(".context", :visible => true).size  }
end

Then /^I see the meta data for context "(.*?)"(.*)*$/ do |context, loading|
  @inspected_resource_element = find(".item_box[data-id='#{@inspected_resource.id}']")
  if loading != ""
    @inspected_resource_element.find(".meta_data .context.#{context.downcase}")
  else
    step 'I see all meta data contexts'
    step 'I wait for the AJAX magic to happen'
    wait_until {@inspected_resource_element.all(".meta_data .context.#{context.downcase}", :visible => true).size > 0}
  end
end

Then /^the resource shows an icon representing its permissions$/ do
  find(".item_box .item_permission")
end

When /^I click that resource$/ do
  @inspected_resource_element.find(".thumb_box_set").click
end

When /^one resource can be taller caused by it's visible meta data$/ do
  # pending
end


