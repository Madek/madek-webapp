###

Create Group

###

GroupsController = {} unless GroupsController?
class GroupsController.Create

  constructor: ->
    do @render
    @form = @el.find "form"
    do @delegateEvents
    new App.Modal @el

  delegateEvents: ->
    @form.on "submit", @onSubmit

  onSubmit: (e)=>
    e.preventDefault()
    group = new App.Group
      name: @form.find("[name='name']").val()
    if group.validate()
      @el.remove()
      group.create => document.location.reload true
    else
      App.DialogErrors.set @form, group.errors

  render: ->
    @el = App.render "groups/create"
    
window.App.GroupsController = {} unless window.App.GroupsController
window.App.GroupsController.Create = GroupsController.Create