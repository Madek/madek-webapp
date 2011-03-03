# -*- encoding : utf-8 -*-
module PermissionsHelper

  # 23.02.11: should be obsolete soon 
  def view_permission_string(resource)
    if resource.acl?(:view, :all)
      "(#{_("Öffentlich")})"
    elsif resource.acl?(:view, :logged_in_users)
      "(#{_("Öffentlich für angemeldete Benutzer")})"
    elsif resource.acl?(:view, :only, current_user)
      "(#{_("Nur für Sie selbst")})"
    else
      # MediaEntries that only I and certain others have access to 
    end  
  end
  
  # caution: only works with new theme
  def display_permission_icon(resource)
    if resource.acl?(:view, :all)
      theme_image_tag("icons/eye.png")
    elsif resource.acl?(:view, :only, current_user)
      theme_image_tag("icons/button_status_private.png")
    end
  end
  
  def display_favorite_icon(resource, user)
    if user.favorites.include?(resource)
      theme_image_tag("icons/button_favorit_on.png")
    else
      theme_image_tag("icons/button_favorit_off.png")
    end
  end
  
  def display_edit_icon(resource, user)
    if user && Permission.authorized?(user, :edit, resource) 
      url = resource.is_a?(MediaEntry) ? edit_media_entry_path(resource) : edit_media_set_path(resource)
      link_to theme_image_tag("icons/button_edit_active.png"), url
    else
      theme_image_tag("icons/button_edit_inactive.png")
    end
  end
  
  def display_delete_icon(resource, user)
    if user && Permission.authorized?(user, :manage, resource) 
      if resource.is_a?(MediaEntry)
        url = media_entry_path(resource)
        confirm = "Sind Sie sicher?"
      else
        url = media_set_path(resource)
        confirm = "Sind Sie sicher? Das Set wird gelöscht."
      end  
      link_to theme_image_tag("icons/button_delete_active.png"), url, :method => :delete, :confirm => confirm
    else
      theme_image_tag("icons/button_delete_inactive.png")
    end
  end

end
