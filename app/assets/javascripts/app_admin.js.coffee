#= require jquery
#= require jquery_ujs
#= require jquery-ui

#= require bootstrap32/transition
#= require bootstrap32/modal
#= require bootstrap32/dropdown
#= require bootstrap32/tab
#= require bootstrap32/tooltip
#= require bootstrap32/popover

#= require_tree ./app_admin

window.jQuery.curCSS = window.jQuery.css

$(document).ready ->
  usersController = new AppAdmin.UsersController.Autocomplete
  $(".limit150, .limit250").tooltip(
    placement: "top"
  )
