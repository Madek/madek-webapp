Then /^I can see the delete action for media resources where I am responsible for$/ do
  all(".ui-resource[data-id]").each do |resource_el|
    media_resource = MediaResource.find resource_el["data-id"]
    if @current_user.authorized?(:delete, media_resource)
      resource_el.find("[data-delete-action]")
    end
  end
end

Then /^I cannot see the delete action for media resources where I am not responsible for$/ do
  all(".ui-resource[data-id]").each do |resource_el|
    media_resource = MediaResource.find resource_el["data-id"]
    if not @current_user.authorized?(:delete, media_resource)
      resource_el.all("[data-delete-action]").size.should == 0
    end
  end
end

Then /^I cannot see the delete action for this resource$/ do
  all(".ui-body-title-actions [data-delete-action]").size.should == 0
end

Then /^I can see the delete action for this resource$/ do
  find(".ui-body-title-actions .primary-button").click
  find("[data-delete-action]")
end