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

    unless group.validate()
      return App.DialogErrors.set @form, group.errors

    group.create (response)=>
      if (err = response.error)?
        App.DialogErrors.set(@form, [{text: err}])
      else
        do document.location.reload
    
  render: ->
    @el = App.render "groups/create"

window.App.GroupsController = {} unless window.App.GroupsController
window.App.GroupsController.Create = GroupsController.Create
