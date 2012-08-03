# -*- encoding : utf-8 -*-
module PermissionsHelper

  def display_permission(resource, type = :icon)
    if resource.is_public?
      if type == :icon
        content_tag :div, :class => "icon_status_perm_public" do end
      else
        "(#{_("Öffentlich")})"
      end
    elsif resource.is_private?(current_user)
      if type == :icon
        content_tag :div, :class => "icon_status_perm_private" do end
      else
        "(#{_("Nur für Sie selbst")})"
      end
    else
      # MediaEntries that only I and certain others have access to 
    end
  end
  
  def display_edit_icon(resource, user)
    if user and user.authorized?(:edit, resource) 
      link_to edit_media_resource_path(resource), :title => "Editieren" do
        content_tag :div, :class => "button_edit_active" do end
      end
    else
      content_tag :div, :class => "button_edit_active ghost" do end
    end
  end
  
  def display_delete_icon(resource, user)
    if user and user.authorized?(:manage, resource) 
      if resource.is_a?(MediaEntry)
        confirm = "Sind Sie sicher?"
      else
        confirm = "Sind Sie sicher? Das Set wird gelöscht."
      end  
      link_to media_resource_path(resource), :title => "Löschen", :method => :delete, :data => {:confirm => confirm} do
        content_tag :div, :class => "button_delete_active" do end
      end
    else
      content_tag :div, :class => "button_delete_active ghost" do end
    end
  end

end
