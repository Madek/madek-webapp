###

  Create new Media Sets (with a thumb box)

  This script provides functionalities for creating a set with a thumb box
 
###

jQuery ->
  $(".thumb_box_set form").live "ajax:beforeSend", (event)->
    $(this).closest(".thumb_box_set").find(".icon").hide()
    $(this).closest(".thumb_box_set").find(".icon").after $.tmpl("tmpl/loading_img")
  $(".thumb_box_set form").live "ajax:success", (event)->
    window.location = window.location
