#= require jquery/jquery-1.11.1
#= require jquery/jquery-migrate-1.2.1.min
#= require jquery_ujs
#= require jquery.ui.all
#= require bootstrap
#= require_tree ./app_admin

window.jQuery.curCSS = window.jQuery.css

$(document).ready ->
  usersController = new AppAdmin.UsersController.Autocomplete
  $(".limit150, .limit250").tooltip(
    placement: "top"
  )
