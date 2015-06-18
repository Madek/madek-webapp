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

    # ╔════════▲═════════════════════════════╗ ▲
    # ║        │  modalMargin                ║ │
    # ║        ▼ ╔════════════════╗ ▲        ║ │
    # ║          ╠════════════════╣ │        ║ │
    # ║          ║................║ │        ║ │
    # ║          ║................║ │        ║ │
    # ║          ║................║ │        ║ │
    # ║          ║.. modalBody  ..║ │        ║ │
    # ║          ║................║ │        ║ │
    # ║          ║................║ │        ║ │
    # ║          ║................║ │ modal  ║ │
    # ║          ╠════════════════╣ │ Height ║ │
    # ║          ╚════════════════╝ ▼        ║ │
    # ║                                      ║ │ windowHeight
    # ╚══════════════════════════════════════╝ ▼


    # add a delay to not be quicker than the DOM reflow :(
    setTimeout =>

      windowHeight = $(window).height()
      modalMargin = @el.position().top # the margin on top of the modal
      modalHeight = @el.outerHeight()
      modalBodyHeight = @el.find(".ui-modal-body").height()

      # complete modal minus modal-body plus 2 margins is space we cant use:
      extraNeededHeight = (modalHeight-modalBodyHeight)+(modalMargin*2)
      # subtract that from the window e presto:
      maximumModalBodyHeight = windowHeight - extraNeededHeight

      # now set it:
      @el.find(".ui-modal-body").css "max-height", maximumModalBodyHeight

    , 125

  onHide: =>
    @el.remove()
    $(window).off "resize", @setModalBodyMaxHeight

  onShown: =>
    do @setModalBodyMaxHeight
    @el.find("[autofocus=autofocus]").focus()
    @el.addClass "ui-shown"

window.App.Modal = Modal
