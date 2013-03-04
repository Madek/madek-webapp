###

warn before drop unsaved data by leaving page, except submiting form

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.WarnOnLeave

  constructor: (options)->
    @el = $(options.el)
    do @delegateEvents

  delegateEvents: =>
    @el.on "change", "*", @setSomethingChanged
    @el.on "submit", @setAcceptLeave
    $(window).on "beforeunload", @checkLeave

  setSomethingChanged: =>
    @somethingChanged = true

  setAcceptLeave: =>
    @acceptLeave = true

  checkLeave: =>  
    if @acceptLeave or not @somethingChanged
      null
    else
      "Nicht gespeicherte Daten gehen verloren. Sind Sie sicher?"
      
window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.WarnOnLeave = FormBehaviours.WarnOnLeave