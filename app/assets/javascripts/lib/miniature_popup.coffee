###

Miniature Popup

This script extends the miniature thumbnails with an hover popup

###

jQuery => 
  active_list = ".active.ui-resources.miniature"
  $("#{active_list} .ui-resource").live "mouseenter", (e)=> 
    target = $(e.currentTarget)
    unless target.data("miniature_popup")
      target.data "miniature_popup", new MiniaturePopup target
    else
      target.data("miniature_popup").show()

class MiniaturePopup

  constructor: (target)->
    @target = $(target)
    @firstMouseMove = 0
    do @createClone
    do @show
    do @delegateEvents

  delegateEvents: ->
    @cloneContainer.on "mouseleave", ".ui-resource", => do @hide

  createClone: ->
    @cloneContainer = App.render "media_resources/miniature_popup"
    @clone = @target.clone()
    @cloneContainer.append @clone

  show: ->
    $("body").append @cloneContainer
    @cloneContainer.position
      my: "center center"
      at: "center center"
      of: @target
    $(window).on "mousemove", @checkMouseMove

  hide: -> 
    do @cloneContainer.detach
    @target.replaceWith @clone
    $(window).off "mousemove", @checkMouseMove
    @firstMouseMove = 0

  checkMouseMove: (e)=>
    unless $(e.target).closest(".ui-resources").is @cloneContainer
      @firstMouseMove++      
      do @hide if @firstMouseMove > 1