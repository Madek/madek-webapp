# -*- encoding : utf-8 -*-
module PermissionsHelper

  def display_permission(resource, type = :icon)
    if resource.acl?(:view, :all)
      if type == :icon
        content_tag :div, :class => "icon_status_perm_public" do end
      else
        "(#{_("Öffentlich")})"
      end
    elsif resource.acl?(:view, :only, current_user)
      if type == :icon
        content_tag :div, :class => "icon_status_perm_private" do end
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
    @permission.subject.id == current_user.id && @permission.media_resource.is_a?(MediaEntry) 
  end
    
  def display_edit_icon(resource, user)
    if user and user.authorized?(:edit, resource) 
      url = resource.is_a?(MediaEntry) ? edit_media_entry_path(resource) : edit_media_set_path(resource)
      link_to url, :title => "Editieren" do
        content_tag :div, :class => "button_edit_active" do end
      end
    else
      content_tag :div, :class => "button_edit_active ghost" do end
    end
  end
  
  def display_delete_icon(resource, user)
    if user and user.authorized?(:manage, resource) 
      if resource.is_a?(MediaEntry)
        url = media_entry_path(resource)
        confirm = "Sind Sie sicher?"
      else
        url = media_set_path(resource)
        confirm = "Sind Sie sicher? Das Set wird gelöscht."
      end  
      link_to url, :title => "Löschen", :method => :delete, :confirm => confirm do
        content_tag :div, :class => "button_delete_active" do end
      end
    else
      content_tag :div, :class => "button_delete_active ghost" do end
    end
  end

end
