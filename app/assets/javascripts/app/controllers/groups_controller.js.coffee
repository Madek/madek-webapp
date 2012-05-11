class GroupsController

  el: "section#content_body"
  
  constructor: ->
    @el = $(@el)
    do @delegate_events
    
  delegate_events: ->
    @el.delegate ".group .button.create", "click", @open_create_dialog 
  
  open_create_dialog: (e)->
    do e.preventDefault
    console.log "OPEN DIALOG"
    return false
  
window.App.Groups = GroupsController