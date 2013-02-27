###

warn before drop unsaved data by leaving page, except submiting form

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.WarnOnLeave

  constructor: ->
    $(window).on "beforeunload", (e)-> 
      if $(e.originalEvent.explicitOriginalTarget).attr("type")? and
      $(e.originalEvent.explicitOriginalTarget).attr("type") == "submit"
        null
      else
        "Nicht gespeicherte Daten gehen verloren. Sind Sie sicher?"
      
window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.WarnOnLeave = FormBehaviours.WarnOnLeave