# -*- encoding : utf-8 -*-

Then /^I open a filter set$/ do
  @resource= @filter_set = @current_user.media_resources.where(:type => "FilterSet").first
  visit filter_set_path @filter_set
end

Then /^I open a media entry where I have all permissions but I am not the responsible user$/ do
  media_entry = MediaEntry.where("user_id not in (?)", @current_user.id).detect{|me| 
    @current_user.authorized?(:view, me) and 
    @current_user.authorized?(:edit, me) and 
    @current_user.authorized?(:download, me) and 
    @current_user.authorized?(:manage, me)
  }
  visit media_resource_path media_entry
end

Then /^I open a media entry where I am the responsible user$/ do
  visit media_resource_path @current_user.media_entries.first
end

Then /^I open a media set where I have all permissions but I am not the responsible user$/ do
  media_entry = MediaEntry.where("user_id not in (?)", @current_user.id).detect{|me| 
    @current_user.authorized?(:view, me) and 
    @current_user.authorized?(:edit, me) and 
    @current_user.authorized?(:download, me) and 
    @current_user.authorized?(:manage, me)
  }
  visit media_resource_path media_entry
end

Then /^I open a media set where I am the responsible user$/ do
  visit media_resource_path @current_user.media_sets.first
end

Then /^I open a specific context$/ do
  @context = @current_user.individual_contexts.find do |context|
    MediaResource.filter(@current_user, {:meta_context_names => [context.name]}).exists?
  end
  visit context_path(@context)
end

Then /^I open one of my media entries that is child of a set that I can see$/ do
  @media_entry =@current_user.media_entries.detect{|me| me.parents.accessible_by_user(@current_user, :edit).size > 0}
  visit media_resource_path @media_entry
end

Then /^I open one of my sets that has children and parents$/ do
  @media_set = @me.media_sets.where(%[ EXISTS (SELECT true FROM media_resource_arcs WHERE child_id = media_resources.id) ]) \
    .where(%[ EXISTS (SELECT true FROM media_resource_arcs WHERE parent_id= media_resources.id) ]).first
  visit media_resource_path @media_set
end

Then /^I open the admin\/users interface$/ do
  visit "admin/users"
end

Then /^I open the dropbox informations dialog$/ do
  step 'The dropbox settings are set-up'
  find(".open_dropbox_dialog").click
  step 'I wait for the dialog to appear'
end

Then /^I open the edit-permissions page/ do
  find("#resource-action-button").click
  find("#view_permissions_of_resource").click
  find("#edit-permissions").click
end

Then /^I open the transfer responsibility page for this resource$/ do
  find("#resource-action-button").click
  find("#view_permissions_of_resource").click
  find("#transfer-responsibilities").click
end


Then /^I open the view-permissions page/ do
  find(".primary-button",text: "Weitere Aktionen").click
  find("a#view_permissions_of_resource").click
end


Then /^I open the filter$/ do
  wait_until { all(".ui-resource").size > 0 }
  find("#ui-side-filter-toggle").click if all("#ui-side-filter-toggle.active").size == 0
  wait_until { all(".ui-side-filter-item").size > 0 }
end

Then /^I open the organize dialog$/ do
  wait_until {all(".app[data-id]").size > 0}
  find(".ui-body-title-actions .primary-button").click
  wait_until {all(".ui-drop-item a[data-organize-arcs]", :visible => true).size > 0}
  all(".ui-drop-item a[data-organize-arcs]", :visible => true).first.click
  step 'I wait for the dialog to appear'
end

Then /^I open the visualization with the hash\-tag test_noupdate_positions$/ do
  visit "/visualization/my_media_resources#test_noupdate_positions"
end
