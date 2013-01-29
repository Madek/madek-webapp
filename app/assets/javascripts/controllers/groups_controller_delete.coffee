###

Delete Group

###

GroupsController = {} unless GroupsController?
class GroupsController.Delete

  constructor: (options)->
    @line = options.line
    @group = new App.Group @line.data()
    @group.fetch =>
      unless @group.isDeletable()
        @el = App.render "groups/undeletable"
      else
        @el = App.render "groups/delete"
      @form = @el.find "form"
      do @delegateEvents
      new App.Modal @el

  delegateEvents: ->
    @form.on "submit", @onSubmit

  onSubmit: (e)=>
    e.preventDefault()
    @el.remove()
    @group.delete => document.location.reload true

window.App.GroupsController = {} unless window.App.GroupsController
window.App.GroupsController.Delete = GroupsController.Delete