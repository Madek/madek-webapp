# -*- encoding : utf-8 -*-

When /^I switch to the list view$/ do
  step 'I go to my media entries'
  wait_until { find("#bar") }
  find("#bar .layout a[data-type=list]").click
end

Then /^each resource is represented as one row of data$/ do
  page.evaluate_script('$(".item_box:first").width()').should > page.evaluate_script('$(".item_box:first").height()')
end

Then /^for each resource I see meta data from the "(.*?)" context$/ do |context|
  @inspected_resource = MediaResource.accessible_by_user(@current_user).last
  @inspected_resource_element = find(".item_box[data-id='#{@inspected_resource.id}']")
  @inspected_meta_data = @inspected_resource.meta_data_for_context(MetaContext.send(context), false)
  @inspected_meta_data.each do |meta_datum|
    @inspected_resource_element.should have_content meta_datum.to_s
  end
end

When /^I see a list of sets in list view$/ do
  visit media_resources_path(:type => "media_sets")
  wait_until { find("#bar .layout .icon[data-type='list']") }.click
end

Then /^for each resource I see a thumbnail image if it is available$/ do
  @inspected_resource_element.find("img")
end

When /^I see the "(.*?)" meta key of a set/ do |meta_key|
  binding.pry
  wait_until(45){ find(".context.nutzung .meta_datum") }
  binding.pry
  case meta_key
    when"children"
      wait_until { find("dt", :text => "Enthält") }
    when "parents"
      wait_until { find("dt", :text => "Enthalten in") }
  end
end

Then /^for each resource I see an icon if no thumbnail is available$/ do
  @inspected_resource_element.find("img")
end

When /^I see a resource in a list view$/ do
  step 'I see a list of resources'
  step 'I switch to the list view'
  @inspected_resource = MediaResource.accessible_by_user(@current_user).last
  @inspected_resource_element = find(".item_box[data-id='#{@inspected_resource.id}']")
end

Then /^I see the number and type of children$/ do
  pending # express the regexp above with the code you wish you had
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

Then /^there is one number for media entries$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the resource's title is highlighted$/ do
  page.evaluate_script('$("dd.title.full").css("fontSize")').to_f.should > page.evaluate_script('$("dd:not(.title)").css("fontSize")').to_f
end

Then /^there is one number for sets$/ do
  pending # express the regexp above with the code you wish you had
end

When /^one resource has more metadata than another$/ do
end

Then /^one of the resources has parents$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the row containing the resource with more metadata is taller than the other$/ do
end

Then /^I see the number and type of parents$/ do
  pending # express the regexp above with the code you wish you had
end