###

FormBehaviour for accepting only submits triggered by submit button

###

FormBehaviours = {} unless FormBehaviours?
class FormBehaviours.PreventEnterSubmit

  constructor: (options)->
    @el = options.el
    do @delegateEvents

  delegateEvents: =>
    @el.on "keypress", @checkKey
    @el.on "submit", @checkSumbit

  checkKey: (e)=>
    if e.keyCode == 13
      @preventSubmit = true
      setTimeout (=> @preventSubmit = false), 200

  checkSumbit: (e)=>    
    if @preventSubmit
      e.preventDefault()
      return false
      
window.App.FormBehaviours = {} unless window.App.FormBehaviours
window.App.FormBehaviours.PreventEnterSubmit = FormBehaviours.PreventEnterSubmit