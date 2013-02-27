###

FormBehaviour for accepting only submits triggered by submit button

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.AcceptOnlyButtonSubmit

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: =>
    @el.on "submit", (e)=>
      if not $(e.originalEvent.explicitOriginalTarget).attr("type")? or
      $(e.originalEvent.explicitOriginalTarget).attr("type") != "submit"  
        e.preventDefault()
        return false
      
window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.AcceptOnlyButtonSubmit = FormBehaviours.AcceptOnlyButtonSubmit