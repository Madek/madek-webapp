###

MediaSet Popup

This script extends the mediaset thumb box of a grid view with an informative popup

###

jQuery ->
  setup()

setup = ->
  $(".item_box.set:not(.popup_target)").live "mouseenter", -> enter_target $(this)
  $(".item_box.set:not(.popup)").live "mouseleave", -> leave_target $(this)
  $(".item_box.set.popup").live "mouseleave", -> leave_popup $(this)
  
enter_target = (target)->
  console.log("ENTER TARGET")
  # clear timeout
  window.clearTimeout($(target).data "popup_timeout")
  # set popup with timeout
  timeout = window.setTimeout -> 
    open_popup target
  , 600
  $(target).data "popup_timeout", timeout
  # set load data with timeout
  timeout = window.setTimeout ->
    load_data target
  , 200
  $(target).data "load_timeout", timeout
  
load_data = (target)->
  console.log "LOAD DATA"
  console.log $(target)
  $.ajax {
    url: "/media_sets/"+target.tmplItem().data.id
    beforeSend: (request, settings) ->
      #before
    success: (data, status, request) ->
      console.log "SUCCESS LOADING"
      setup_childs(data)
    error: (request, status, error) ->
      console.log "ERROR LOADING"
    data:
      format: "json"
      with: 
        media_set:
          media_resources:
            type: 1
            image:
              as:"base64"
              size:"small"
    type: "GET"
  }
  
setup_childs = (data)->
  
  
open_popup = (target)->
  console.log("OPEN POPUP")
  # mark target
  $(target).addClass("popup_target")
  # create if not exist
  if($(target).data("popup") == undefined) 
    create_popup target
  # fadein childs and parents
  $($(target).data("popup")).find(".child_entries").fadeIn(300, ->
    $(this).find(".arrow").show()
  )
  $($(target).data("popup")).find(".parent_sets").fadeIn(300, ->
    $(this).find(".arrow").show()
  )
  # animate opening
  $($(target).data("popup")).find(".background").animate {
    left: 0,
    height: "650px",
    top: "-130px",
    width: "200px"
  }
    
  
create_popup = (target)->
  console.log("CREATE POPUP")
  # create copy of target
  copy = $(target).clone(false)
  copy.addClass("popup")
  # create a background
  arrow_grey = $.tmpl "tmpl/svg/arrow", classname: "grey"
  arrow_white = $.tmpl "tmpl/svg/arrow", classname: "white"
  background = $("<div class='background'></div>")
  background.append $("<div class='parent_sets'></div>")
  # create parent sets container
  parent_sets = $(background).find ".parent_sets"
  parent_sets.hide() 
  parent_sets.append arrow_grey
  background.append $("<div class='child_entries'></div>")
  # create child entries container
  child_entries = $(background).find ".child_entries"
  child_entries.append $("<div class='bar'></div>")
  child_entries.find(".bar").append arrow_white
  child_entries.hide()
  # hide arrows
  $(background).find(".arrow").hide() 
  background.css("width", "140px").css("height", "235px").css("position", "absolute").css("top", "6px").css("left", "25px")
  # create container
  container = $("<div class='set_popup'></div>")
  container.css("width", "200px").css("position", "absolute").css("z-index", "1000")
  # add pop up to target
  $(target).data "popup", container
  # add target to data
  $(container).data "target", target
  # add to dom
  container.append background
  container.append copy
  $("body").append container
  # positioning
  $(container).position {
    my: "top left",
    at: "top left",
    of: $(target)
  }
  $(copy).position {
    my: "top left",
    at: "top left",
    of: $(target)
  }
  
close_popup = (popup_container)->
  console.log("CLOSE POPUP")
  # clear timeouts
  window.clearTimeout($(popup_container).data("popup_timeout"))
  window.clearTimeout($(popup_container).data("load_timeout"))
  # hide arrows
  $(popup_container).find(".arrow").hide()
  # animate closing
  background = $(popup_container).find ".background"
  $(background).animate {
    left: "25px",
    top: "0",
    height: "235px",
    width: "140px"
  }, ->
    # remove popup from dom
    remove_popup popup_container
  
remove_popup = (popup_container)->
  console.log("REMOVE POPUP")
  target = $(popup_container).data("target")
  $(target).removeClass("popup_target")
  $(target).removeData("popup")
  $(popup_container).remove()

leave_target = (target)->
  console.log("LEAVE TARGET")
  if $(target).data("popup") == undefined
    close_popup target
  
leave_popup = (popup)->
  console.log("LEAVE POPUP")
  target = $(popup).closest(".set_popup")
  close_popup target
      