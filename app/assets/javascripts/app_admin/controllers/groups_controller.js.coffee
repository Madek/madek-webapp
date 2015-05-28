###

Autocomplete Groups

###

GroupsController = {} unless GroupsController?
class GroupsController.Autocomplete

  constructor: (options)->
    @form = $("form.group-autocomplete")
    @textField = @form.find(".form-control")
    @groupId = @form.find("[name='[group_id]']")
    @submitButton = @form.find("button")
    @delegateEvents()

  delegateEvents: ->
    @form.on "submit", (e)=>
      false if @submitButton.prop("disabled")
    @textField.on "focus", (e)=>
      @setupAutocomplete($(e.currentTarget)) unless $(e.currentTarget).hasClass "ui-autocomplete-input"

  setupAutocomplete: (input)->
    input.autocomplete
      appendTo: input.closest ".col-sm-4"
      source: (request, response) =>
        @resetGroup()
        @ajax.abort() if @ajax?
        @ajax = AppAdmin.Group.fetch request.term, (groups)->
          response($.map groups, (group)-> 
            id: group.id 
            name: group.name
            value: group.name
          )
      select: (event, ui) =>
        @addGroup new AppAdmin.Group
          id: ui.item.id
        @enableSubmit()

  addGroup: (user)=>
    @groupId.val(user.id)

  resetGroup: ->
    @disableSubmit()
    @groupId.val('')

  enableSubmit: ->
    @submitButton.prop("disabled", false)

  disableSubmit: ->
    @submitButton.prop("disabled", true)

window.AppAdmin = {} unless window.AppAdmin
window.AppAdmin.GroupsController = {} unless window.AppAdmin.GroupsController
window.AppAdmin.GroupsController.Autocomplete = GroupsController.Autocomplete
