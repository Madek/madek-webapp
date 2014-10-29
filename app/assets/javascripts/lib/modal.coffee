###

App.modal

This script provides functionalities for client side rendered modal dialogs.

It also autofocus fields that have the autofocus attribute

###

class Modal

  constructor: (el)->
    @el = $(el)
    do @delegateEvents
    @el.modal @el

  delegateEvents: ->
    @el.on "hidden.bs.modal", @onHide
    @el.on "shown.bs.modal", @onShown
    $(window).on "resize", @setModalBodyMaxHeight
    
  setModalBodyMaxHeight: =>
    windowHeight = $(window).height()
    rim =  ( @el.position().top - $(document).scrollTop() )*2
    elHeight = @el.outerHeight()
    elBodyHeight = @el.find(".ui-modal-body").height()
    height =  windowHeight - rim - elHeight  + elBodyHeight 
    @el.find(".ui-modal-body").css "max-height", height

  onHide: =>
    @el.remove()
    $(window).off "resize", @setModalBodyMaxHeight

  onShown: =>
    do @setModalBodyMaxHeight
    @el.find("[autofocus=autofocus]").focus()
    @el.addClass "ui-shown"

window.App.Modal = Modal
