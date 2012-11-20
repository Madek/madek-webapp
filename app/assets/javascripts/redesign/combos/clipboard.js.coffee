$(document).ready ->
  $(".clipboard-content").fadeOut "fast"
  $("#clipboard-toggle").click ->
    $(".app-clipboard .clipboard-content").slideToggle "slow"
    $(".app-clipboard").toggleClass "closed"
    $(body).toggleClass "clipboard-open"

  # Clear Clipboard Functionality

  $(".clipboard-clear").click ->
    $(".clipboard-entries-item").remove()
    $(".clipboard-entries").hide()
    $(".clipboard-alert").show()
