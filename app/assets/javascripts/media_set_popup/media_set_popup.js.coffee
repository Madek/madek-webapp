###

MediaSet Popup

This script extends the mediaset thumb box of a grid view with an informative popup

###

jQuery ->
  setup()

setup = ->
  $(".item_box.set:not(.popup_target) .thumb_box_set").live "mouseenter", -> enter_target $(this)
  $(".item_box.set.popup_target:not(.popup) .thumb_box_set").live "mouseenter", -> enter_target $(this)
  $(".item_box.set:not(.popup_target) .thumb_box_set").live "click", -> stop_target_popup $(this)
  $(".item_box.set:not(.popup) .thumb_box_set").live "mouseleave", -> leave_target $(this)

stop_target_popup = (target) ->
  target = $(target).closest(".item_box")
  window.clearTimeout($(target).data "popup_timeout")

enter_target = (target)->
  target = $(target).closest(".item_box")
  window.clearTimeout($(target).data "popup_timeout")
  $(target).data "popup_timeout", window.setTimeout -> 
    open_popup target
  , 800
  $(target).data "load_timeout", window.setTimeout ->
    load_children target
    load_parents target
  , 100
  
load_children = (target)->
  if $(target).data("loaded_children")?
    setup_children(target, $(target).data("loaded_children"))
  else
    $.ajax
      url: "/media_sets/"+target.tmplItem().data.id+".json"
      data:
        with: 
          children: true
          meta_data:
            meta_key_names: ["title"]
          image:
            as:"base64"
            size:"small"
      type: "GET"
      success: (data, status, request) ->
        $(target).data "loaded_children", data
        setup_children(target, data)
      error: (request, status, error) ->
        console.log "ERROR LOADING"
    
load_parents = (target)->
  if $(target).data("loaded_parents")?
    setup_parents(target, $(target).data("loaded_parents"))
  else
    $.ajax
      url: "/media_sets/"+target.tmplItem().data.id+".json"
      data:
        with:
          meta_data:
            meta_key_names: ["title"]
          parents: true
          image:
            as:"base64"
            size:"small"
      type: "GET"
      success: (data, status, request) ->
        $(target).data "loaded_parents", data
        setup_parents(target, data)
      error: (request, status, error) ->
        console.log "ERROR LOADING"

pluralize_resource_by_type = (type) ->
  switch type
    when "media_set" then "media_sets"
    when "media_entry" then "media_entries"

resource_setdiv_template= ->
  """   <div class="set_bg"> </div>
        <div class="set_label_shadow"> </div>
        <div class="set_label"> </div>
  """
  
resource_template= (resource)->
  meta_data = MetaDatum.flatten resource.meta_data
  """<a href="#{pluralize_resource_by_type(resource.type)}/#{resource.id}">
      <div class="resource #{resource.type}" title="#{meta_data.title}">
        #{if resource.type is 'media_set' then resource_setdiv_template() else ''}
        <img src="#{resource.image}" />
      </div>
     </a>
     """
setup_children = (target, data)->
  if $(target).data("popup")?
    # remove loading
    $($(target).data("popup")).find(".children .loading").remove()
    # setup resources
    media_entries = (resource for resource in data.children when resource.type is "media_entry")
    media_sets = (resource for resource in data.children when resource.type is "media_set")
    resources = data.children[0...6]
    displayed_media_entries = (resource for resource in resources when resource.type is "media_entry")
    displayed_media_sets = (resource for resource in resources when resource.type is "media_set")
    for resource in resources
      do (resource) ->
        $($(target).data("popup")).find(".children").append resource_template(resource) 
    # setup text
    $($(target).data("popup")).find(".children").append $("<div class='text'></div>")
    if media_entries? then $($(target).data("popup")).find(".children .text").append("<p>"+(media_entries.length-displayed_media_entries.length)+" weitere Medieneinträge</p>")
    if media_sets? then $($(target).data("popup")).find(".children .text").append("<p>"+(media_sets.length-displayed_media_sets.length)+" weitere Sets</p>")
      
setup_parents = (target, data)->
  if $(target).data("popup")?
    # remove loading
    $($(target).data("popup")).find(".parents .loading").remove()
    # setup resources
    resources = data.parents[0...3]
    displayed_media_sets = (resource for resource in resources when resource.type is "media_set")
    for resource in resources
      do (resource) ->
        $($(target).data("popup")).find(".parents").append resource_template(resource)
    # setup text
    $($(target).data("popup")).find(".parents").append $("<div class='text'></div>")
    if resources? then $($(target).data("popup")).find(".parents .text").append("<p>"+(data.parents.length-displayed_media_sets.length)+" weitere Sets</p>")
      
open_popup = (target)->
  $(".set_popup").each (i, element)-> close_popup element
  $(target).addClass("popup_target")
  create_popup target if($(target).data("popup") == undefined) 
  $($(target).data("popup")).find(".children").find(".arrow").show()
  $($(target).data("popup")).find(".children").delay(150).fadeIn(300)
  $($(target).data("popup")).find(".parents").find(".arrow").show()
  $($(target).data("popup")).find(".parents").delay(150).fadeIn(300)
  $($(target).data("popup")).find(".background").animate {
    left: 0,
    height: "665px",
    top: "-145px",
    width: "200px"
  }, 200
  
create_popup = (target)->
  # create copy of target
  copy = $(target).clone()
  copy.addClass("popup")
  # create a background
  arrow_grey = $.tmpl "tmpl/svg/arrow", classname: "grey"
  arrow_white = $.tmpl "tmpl/svg/arrow", classname: "white"
  background = $("<div class='background'></div>")
  background.append $("<div class='parents'></div>")
  # create parent sets container
  parents = $(background).find ".parents"
  parents.append $("<div class='loading'><img src='/assets/loading.gif'/></div>")
  parents.hide() 
  parents.append arrow_grey
  background.append $("<div class='children'></div>")
  # create child entries container
  children = $(background).find ".children"
  children.append $("<div class='bar'></div>")
  children.append $("<div class='loading'><img src='/assets/loading.gif'/></div>")
  children.find(".bar").append arrow_white
  children.hide()
  # hide arrows
  $(background).find(".arrow").hide() 
  background.css("width", "140px").css("height", "235px").css("position", "absolute").css("top", "6px").css("left", "25px")
  # create container
  container = $("<div class='set_popup'></div>")
  container.css("width", "200px").css("position", "absolute").css("z-index", "9999")
  # add pop up to target
  $(target).data "popup", container
  # add target to data
  $(container).data "target", target
  # add to dom
  container.append background
  container.append copy
  $("body").append container
  # positioning
  offset = if $(".media_resources.index.miniature").length then "0 40" else 0 
  $(container).position {
    my: "top left",
    at: "top left",
    offset: offset,
    of: $(target)
  }
  $(copy).position {
    my: "top left",
    at: "top left",
    offset: offset,
    of: $(target)
  }
  # put children inside if already exist
  if $(target).data("loaded_children")?
    setup_children target, $(target).data("loaded_children")
  # put parents inside if already exist
  if $(target).data("loaded_parents")?
    setup_parents target, $(target).data("loaded_parents")
  # bind mouse leave
  $(".set_popup").bind "mouseleave", -> leave_popup $(this)
  
close_popup = (popup_container)->
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
  }, 300, ->
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
  target = $(target).closest(".item_box")
  if $(target).data("popup") == undefined
    close_popup target
  
leave_popup = (popup)->
  target = $(target).closest(".item_box")
  target = $(popup).closest(".set_popup")
  close_popup target
      

