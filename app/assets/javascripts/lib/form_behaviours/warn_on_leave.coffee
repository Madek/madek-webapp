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
    @el.on "change", "*", ->
      @somethingChanged = true
    
    # when submitting, don't call the check!
    @el.on "submit", ->
      $(window).off "beforeunload"
    
    # when otherwise trying to leave, check!
    $(window).on "beforeunload", @checkBeforeLeaving

  checkBeforeLeaving: =>
    if @somethingChanged
      null
    else
      "Nicht gespeicherte Daten gehen verloren. Sind Sie sicher?"
      
window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.WarnOnLeave = FormBehaviours.WarnOnLeave
