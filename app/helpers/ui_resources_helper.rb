module UiResourcesHelper

  def ui_resources_class
    resources_class = current_user.is_guest? ? [] : ["active"]
    resources_class.push active_layout || "grid"
    resources_class.join " "
  end

end