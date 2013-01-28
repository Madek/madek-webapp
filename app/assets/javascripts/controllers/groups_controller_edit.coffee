###

Edit Group

###

GroupsController = {} unless GroupsController?
class GroupsController.Edit

  constructor: (options)->
    @line = options.line
    @group = new App.Group @line.data()
    @group.fetch =>
      @el = App.render "groups/edit", @group
      @form = @el.find "form"
      console.log @form
      @userList = @el.find "#user-list"
      @editNameContainer = @el.find "#edit-name-container"
      @groupNameInput = @editNameContainer.find "#group-name"
      do @renderUsers
      do @delegateEvents
      new App.Modal @el

  delegateEvents: ->
    @form.on "submit", @onSubmit
    @el.on "click", "[data-remove-user]", (e)=> @removeUser $(e.currentTarget).closest("tr")
    @el.on "focus", "#add-user", (e)=> @setupAutocomplete($(e.currentTarget)) unless $(e.currentTarget).hasClass "ui-autocomplete-input"
    @el.on "click", "#show-edit-name", @showEditName
    @groupNameInput.on "change", => @group.name = @groupNameInput.val()

  setupAutocomplete: (input)->
    input.autocomplete
      appendTo: input.closest ".form-item"
      source: (request, response)->
        @ajax.abort() if @ajax?
        @ajax = App.User.fetch request.term, (users)->
          response _.map users, (user)-> 
            id: user.id 
            name: user.name
            value: user.name
      select: (event, ui)=>
        @addUser new App.User
          id: ui.item.id
          name: ui.item.name
        input.val ""
        return false

  addUser: (user)=>
    @group.addUser user
    do @renderUsers

  renderUsers: -> @userList.html App.render "groups/edit/user_list", _.sortBy @group.users, (user)-> user.toString()

  removeUser: (line)-> 
    if @group.users.length > 1
      @group.removeUser new App.User line.data()
      line.fadeOut 200, => line.remove()
    else
      App.DialogErrors.set @el, [{text: "Der letzte Benutzer einer Gruppe kann nicht gelöscht werden."}]

  showEditName: (e)=>
    $(e.currentTarget).hide()
    @editNameContainer.show()
    @groupNameInput.select().focus()

  onSubmit: (e)=>
    e.preventDefault()
    if @group.validate()
      @el.remove()
      @group.update => document.location.reload true
    else
      App.DialogErrors.set @editNameContainer, @group.errors

window.App.GroupsController = {} unless window.App.GroupsController
window.App.GroupsController.Edit = GroupsController.Edit