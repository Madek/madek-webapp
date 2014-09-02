#= require jquery
#= require jquery_ujs
#= require jquery-ui
#= require bootstrap
#= require_tree ./app_admin

window.jQuery.curCSS = window.jQuery.css

$(document).ready ->
  usersController = new AppAdmin.UsersController.Autocomplete
  $(".limit150, .limit250").tooltip(
    placement: "top"
  )
