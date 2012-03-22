def open_permissions
  find(".button_permissions").click()
  wait_for_css_element(".me .line")
end
