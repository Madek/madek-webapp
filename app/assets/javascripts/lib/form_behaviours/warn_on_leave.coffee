###

warn before drop unsaved data by leaving page, except submiting form

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.WarnOnLeave

  constructor: (options)->
    @el = $(options.el)
    do @delegateEvents

  delegateEvents: =>
    # if any input changed, mark as dirty
    @el.on "change", "*", =>
      @somethingChanged = true
    
    # when submitting, don't call the check!
    @el.on "submit", ->
      $(window).off "beforeunload"
    
    # when otherwise trying to leave, check!
    $(window).on "beforeunload", @checkBeforeLeaving

  checkBeforeLeaving: (event)=>
    msg = "Nicht gespeicherte Daten gehen verloren. Sind Sie sicher?"
    
    if @somethingChanged
      (event || window.event).preventDefault()     # Fallback
      (event || window.event).returnValue = msg    # Gecko + IE
      return msg                                   # Webkit, Safari, Chrome etc.


window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.WarnOnLeave = FormBehaviours.WarnOnLeave
