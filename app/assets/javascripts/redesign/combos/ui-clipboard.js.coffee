$ ->
  setTimeout (->
    $(".ui-clipboard-content").animate
      opacity: 0
      height: 0
      specialEasing:
        width: "linear"
        height: "easeOutBounce"

      complete: ->
        return $(this).hide()
        $(this).css "opacity: 1, height: auto"
  ), 5000

$("#clipboard-toggle").click ->
  $(".ui-clipboard .ui-clipboard-content").slideToggle "fast"
  $(".ui-clipboard").toggleClass "closed"
  $(body).toggleClass "ui-clipboard-open"

# Clear Clipboard Functionality

$(".ui-clipboard-clear").click ->
  $(".ui-clipboard-entries-item").remove()
  $(".ui-clipboard-entries").hide()
  $(".ui-clipboard-alert").show()
