###

Groups Index

###

GroupsController = {} unless GroupsController?
class GroupsController.Index

  constructor: (options)->
    @el = $(options.el)
    do @delegateEvents   

  delegateEvents: ->
    @el.on "click", "#create-workgroup", => new App.GroupsController.Create
    @el.on "click", ".delete-workgroup", (e)=> new App.GroupsController.Delete {line: $(e.currentTarget).closest("tr")}
    @el.on "click", ".edit-workgroup", (e)=> new App.GroupsController.Edit {line: $(e.currentTarget).closest("tr")}

window.App.GroupsController = {} unless window.App.GroupsController
window.App.GroupsController.Index = GroupsController.Index