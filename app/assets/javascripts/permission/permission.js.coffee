###

Permission

This script provides functionalities for setting and viewing persmissions

###

jQuery ->
  $(".open_permission_lightbox").live("click", Permission.open_lightbox)

class Permission
  
  @open_lightbox = (event)->
    Dialog.add
      trigger: event.currentTarget
      dialogClass: "permission_lightbox"
      content: $.tmpl("tmpl/permission/lightbox")
   
window.Permission = Permission