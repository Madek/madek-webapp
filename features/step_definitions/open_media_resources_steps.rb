When /^I open a media entry where I have all permissions but I am not the responsible user$/ do
  media_entry = MediaEntry.where("user_id not in (?)", @current_user.id).detect{|me| 
    @current_user.authorized?(:view, me) and 
    @current_user.authorized?(:edit, me) and 
    @current_user.authorized?(:download, me) and 
    @current_user.authorized?(:manage, me)
  }
  visit media_resource_path media_entry
end

When /^I open a media entry where I am the responsible user$/ do
  visit media_resource_path @current_user.media_entries.first
end

When /^I open a media set where I have all permissions but I am not the responsible user$/ do
  media_entry = MediaEntry.where("user_id not in (?)", @current_user.id).detect{|me| 
    @current_user.authorized?(:view, me) and 
    @current_user.authorized?(:edit, me) and 
    @current_user.authorized?(:download, me) and 
    @current_user.authorized?(:manage, me)
  }
  visit media_resource_path media_entry
end

When /^I open a media set where I am the responsible user$/ do
  visit media_resource_path @current_user.media_sets.first
end