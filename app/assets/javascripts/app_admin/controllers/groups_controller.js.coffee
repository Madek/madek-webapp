###

Edit Group

###

GroupsController = {} unless GroupsController?
class GroupsController.Edit

  constructor: (options)->
    @form = $("#add-group-user")
    @textField = @form.find(".form-control")
    @userId = @form.find("[name='[user_id]']")
    @submitButton = @form.find("button")
    @delegateEvents()

  delegateEvents: ->
    @form.on "submit", (e)=>
      false if @submitButton.prop("disabled")
    @textField.on "focus", (e)=>
      @setupAutocomplete($(e.currentTarget)) unless $(e.currentTarget).hasClass "ui-autocomplete-input"
    @textField.on "keyup", (e)=>
      @checkIfLogin()

  setupAutocomplete: (input)->
    input.autocomplete
      appendTo: input.closest ".col-sm-4"
      source: (request, response) =>
        return if @checkIfLogin()
        @resetUser()
        @ajax.abort() if @ajax?
        @ajax = AppAdmin.User.fetch request.term, (users)->
          response($.map users, (user)-> 
            id: user.id 
            name: user.name
            value: "#{user.name} [#{user.login}]"
          )
      select: (event, ui) =>
        @addUser new AppAdmin.User
          id: ui.item.id
        @enableSubmit()

  addUser: (user)=>
    @userId.val(user.id)

  resetUser: ->
    @disableSubmit()
    @userId.val('')

  checkIfLogin: ->
    if /^\[\w+\]$/.test(@textField.val())
      @enableSubmit()

  enableSubmit: ->
    @submitButton.prop("disabled", false)

  disableSubmit: ->
    @submitButton.prop("disabled", true)

window.AppAdmin = {} unless window.AppAdmin
window.AppAdmin.GroupsController = {} unless window.AppAdmin.GroupsController
window.AppAdmin.GroupsController.Edit = GroupsController.Edit
