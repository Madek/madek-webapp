# -*- encoding : utf-8 -*-
module PermissionsHelper

  def display_permission(resource, type = :icon)
    if resource.acl?(:view, :all)
      if type == :icon
        image_tag("icons/icon_status_perm_public.png")
      else
        "(#{_("Öffentlich")})"
      end
    elsif resource.acl?(:view, :only, current_user)
      if type == :icon
        image_tag("icons/icon_status_perm_private.png")
      else
        "(#{_("Nur für Sie selbst")})"
      end
    else
      # MediaEntries that only I and certain others have access to 
    end
  end
  
  
  # used to ajax update download partial when user changes download permission for himself
  def changing_own_permission
    return false if @permission.subject.blank?
    @permission.subject.id == current_user.id && @permission.resource.is_a?(MediaEntry) 
  end
  
  # TODO move to media_entries_helper.rb
  def display_favorite_icon(resource, user)
    s = (user.favorite_ids.include?(resource.id) ? "on" : "off") # (user.favorites.include?(resource) ? "on" : "off")
    image_tag("icons/button_favorit_#{s}.png")
  end
  
  def display_edit_icon(resource, user)
    if user && Permission.authorized?(user, :edit, resource) 
      url = resource.is_a?(MediaEntry) ? edit_media_entry_path(resource) : edit_media_set_path(resource)
      link_to image_tag("icons/button_edit_active.png"), url, :title => "Editieren"
    else
      image_tag("icons/button_edit_inactive.png")
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
      link_to image_tag("icons/button_delete_active.png"), url, :title => "Löschen", :method => :delete, :confirm => confirm
    else
      image_tag("icons/button_delete_inactive.png")
    end
  end

end
