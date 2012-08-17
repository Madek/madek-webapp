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
  
end
