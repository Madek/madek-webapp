#= require jquery/jquery.min
#= require jquery_ujs
#= require jquery-ui
#= require bootstrap
#= require_tree ./app_admin

window.jQuery.curCSS = window.jQuery.css

$(document).ready ->
  groupsController = new AppAdmin.GroupsController.Edit
  $(".limit150, .limit250").tooltip(
    placement: "top"
  )
