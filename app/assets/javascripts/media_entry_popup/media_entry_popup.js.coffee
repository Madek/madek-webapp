###

MediaEntry Popup

This script extends the mediaentry thumb box of a grid view with an informative popup

###

jQuery ->
  setup()

setup = ->
  $(".media_resources.miniature.index .item_box:not(.set):not(.popup_target) .thumb_box").live "mouseenter", -> enter_target $(this)
  $(".media_resources.miniature.index .item_box:not(.set).popup_target:not(.popup) .thumb_box").live "mouseenter", -> enter_target $(this)
  $(".media_resources.miniature.index .item_box:not(.set):not(.popup_target) .thumb_box").live "click", -> stop_target_popup $(this)
  $(".media_resources.miniature.index .item_box:not(.set):not(.popup) .thumb_box").live "mouseleave", -> leave_target $(this)

stop_target_popup = (target) ->
  target = $(target).closest(".item_box")
  window.clearTimeout($(target).data "popup_timeout")

enter_target = (target)->
  target = $(target).closest(".item_box")
  window.clearTimeout($(target).data "popup_timeout")
  $(target).data "popup_timeout", window.setTimeout -> 
    open_popup target
  , 800

open_popup = (target)->
  $(".entry_popup").each (i, element)-> close_popup element
  $(target).addClass("popup_target")
  create_popup target if($(target).data("popup") == undefined) 
  
create_popup = (target)->
  # create copy of target
  copy = $(target).clone()
  copy.addClass("popup")
  # create container
  container = $("<div class='entry_popup'></div>")
  container.css
    "width": copy.outerWidth()
    "position": "absolute"
    "z-index": 9999
  # add pop up to target
  $(target).data "popup", container
  # add target to data
  $(container).data "target", target
  # add to dom
  $(container).append copy
  $(container).hide()
  $("body").append container
  # positioning
  $(container).position 
    my: "top left",
    at: "top left",
    of: $(target)
    offset: "0 25px"
  $(container).show()
  $(container).bind "mouseleave", -> leave_popup $(this)
  
close_popup = (popup_container)->
  # clear timeouts
  window.clearTimeout($(popup_container).data("popup_timeout"))
  window.clearTimeout($(popup_container).data("load_timeout"))
  # TODO: animate closing 
  # remove popup from dom
  remove_popup popup_container
  
remove_popup = (popup_container)->
  target = $(popup_container).data("target")
  $(target).removeData("popup")
  $(popup_container).remove()
  window.setTimeout ->
    $(target).removeClass("popup_target")
  , 200

leave_target = (target)->
  container = $(target).closest(".item_box")
  window.clearTimeout($(container).data("popup_timeout"))
  window.clearTimeout($(container).data("load_timeout"))
  
leave_popup = (popup)->
  target = $(target).closest(".item_box")
  target = $(popup).closest(".entry_popup")
  close_popup target
      

