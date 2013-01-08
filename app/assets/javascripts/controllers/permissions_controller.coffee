###

Permissions

###

class Permissions

  constructor: (el)->
    @manageable = el.data "manageable"
    @showDialog el
    do @delegateEvents
    App.PermissionPreset.fetch null, (presets)=>
      @permissionPresets = presets
      if el.data("media-resource-id")?
        @mediaResourceIds = [el.data("media-resource-id")]
        @mediaResourceId = el.data("media-resource-id")
        do @fetchPermissions
      else if el.data("collection")?
        @collection = el.data("collection")
        @mediaResourceIds = @collection.ids
        do @fetchPermissions

  delegateEvents: ->
    @dialog.on "change", ".ui-rights-check input", @onChangePermission
    @dialog.on "change", ".ui-rights-role select", (e)=> @onChangePreset $(e.currentTarget)
    @dialog.on "click", ".ui-rights-role select option", (e)=> @onChangePreset $(e.currentTarget).closest "select"
    @dialog.on "click keydown", ".ui-add-subject .button", (e)=> @showAddInput $(e.currentTarget)
    @dialog.on "click", ".ui-rights-remove", (e)=> $(e.currentTarget).closest("tr").remove()
    @dialog.on "change", ".ui-rights-owner input", (e)=> @changeOwnerTo $(e.currentTarget).closest "tr"
    @dialog.on "change", ".ui-rights-management-public .ui-rights-check input", @onChangePublicPermission
    @form.on "submit", @savePermissions

  savePermissions: (e)=>
    do e.preventDefault
    userPermissions = _.map @otherUsersContainer.find("tr"), (line)=> @getPermissionDataFromLine $(line)
    userPermissions.push @getPermissionDataFromLine @currentUserLine
    groupPermissions = _.map @otherGroupsContainer.find("tr"), (line)=> @getPermissionDataFromLine $(line)
    groupPermissions = groupPermissions.concat _.map @currentUserGroupsContainer.find("tr"), (line)=> @getPermissionDataFromLine $(line)
    publicPermissions = _.map @publicPermissionsContainer.find("tr"), (line)=> @getPermissionDataFromLine $(line)
    ownerLine = @rightsContainer.find(".ui-rights-owner input:checked").closest "tr"
    owner = if ownerLine.length then ownerLine.data("id") else undefined
    do @dialog.remove
    App.Permission.storeMultiple
      users: userPermissions
      groups: groupPermissions
      public: publicPermissions[0]
      owner: owner
    , @mediaResourceIds, (response)-> document.location.reload true
    return false

  getPermissionDataFromLine: (line)->
    id: line.data "id"
    view: @getPermission "view", line
    download: @getPermission "download", line
    edit: @getPermission "edit", line
    manage: @getPermission "manage", line

  getPermission: (name, line)-> 
    line.find("input[name='#{name}']:checked").length > 0

  onChangePublicPermission: =>
    if @publicPermissionsContainer.find(".ui-rights-check input[name='view']:checked").length
      @rightsContainer.addClass "public-view"
    else
      @rightsContainer.removeClass "public-view"
    if @publicPermissionsContainer.find(".ui-rights-check input[name='download']:checked").length
      @rightsContainer.addClass "public-download"
    else
      @rightsContainer.removeClass "public-download"
    if @publicPermissionsContainer.find(".ui-rights-check input[name='edit']:checked").length
      @rightsContainer.addClass "public-edit"
    else
      @rightsContainer.removeClass "public-edit"

  changeOwnerTo: (newOwnerLine)->
    previousOwnerLine = @rightsContainer.find("[data-ownership='true']")
    previousOwnerLine.replaceWith App.render "permissions/line", 
      id: previousOwnerLine.data "id"
      name: previousOwnerLine.data "name"
      view: true
      download: true
      edit: true
      manage: true
      ownership: false
    ,
      presets: @permissionPresets
      manageable: @manageable
    newOwnerLine.replaceWith App.render "permissions/line", 
      id: newOwnerLine.data "id"
      name: newOwnerLine.data "name"
      view: true
      download: true
      edit: true
      manage: true
      ownership: true
    ,
      presets: @permissionPresets
      manageable: @manageable

  showDialog: (el)->
    @dialog = App.render "permissions/dialog", {title: el.data "title"}, {manageable: @manageable}
    @saveButton = @dialog.find "button[type='submit']"
    @form = @dialog.children "form"
    @rightsContainer = @dialog.find ".ui-rights-management"
    App.modal @dialog

  setupaddUser: ->
    setup = =>
      input = @addUserContainer.find("input")
      input.autocomplete
        appendTo: @dialog
        source: (request, response)->
          @ajaxSearchPerson.abort() if @ajaxSearchPerson?
          @ajaxSearchPerson = App.User.fetch request.term, (users)->
            users = _.filter users, (user) -> user.id != currentUser.id
            response _.map users, (user)-> 
              _user = JSON.parse JSON.stringify user
              _user.value = user.name
              _user
        select: (event, ui)=>
          @addPermissionForSubject new App.User {id: ui.item.id, name: ui.item.name}
          $(event.target).blur()
          $(event.target).nextAll(".button").focus()
          return false
      input.autocomplete("widget").addClass("narrow")
    # setup if dialog is visible (possible time shift because the bootstrap modal)
    if @dialog.is ":visible" then do setup else @dialog.one "shown", => do setup

  setupAddGroup: ->
    setup = =>
      input = @addGroupContainer.find("input")
      input.autocomplete
        appendTo: @dialog
        source: (request, response)->
          @ajaxSearchPerson.abort() if @ajaxSearchPerson?
          @ajaxSearchPerson = App.Group.fetch request.term, (groups)->
            response _.map groups, (group)-> 
              _group = JSON.parse JSON.stringify group
              _group.value = group.name
              _group
        select: (event, ui)=>
          @addPermissionForSubject new App.Group {id: ui.item.id, name: ui.item.name}
          $(event.target).blur()
          $(event.target).nextAll(".button").focus()
          return false
      input.autocomplete("widget").addClass("narrow")
    # setup if dialog is visible (possible time shift because the bootstrap modal)
    if @dialog.is ":visible" then do setup else @dialog.one "shown", => do setup

  addPermissionForSubject: (subject) =>
    return true if @rightsContainer.find("[data-id=#{subject.id}]").length
    line = App.render "permissions/line", 
      id: subject.id
      name: subject.name
      view: true
      download: false
      edit: false
      manage: false
      ownership: false
    ,
      presets: @permissionPresets
      manageable: @manageable
    target = if subject instanceof App.User
      @otherUsersContainer.find("tbody")
    else if subject instanceof App.Group
      if currentUser.isMemberOf subject
        @currentUserGroupsContainer.show().find("tbody")
      else
        @otherGroupsContainer.find("tbody")
    target.append line

  showAddInput: (button)=>
    input = button.prevAll "input"
    button.hide()
    input.show()
    input.one "blur", (e)-> input.hide() and input.val("") and button.show()
    input.focus()

  onChangePreset: (select)=>
    option = select.find("option:selected")
    line = select.closest "tr"
    @setPresetFor line, option.data "preset"

  onChangePermission: (e)=>
    el = $(e.currentTarget).closest "tr"
    @switchPresetForElement el, @getPresetForElement(el)

  getPresetForElement: (el)->
    elPermissions =
      view: el.find("input[name='view']").is ":checked"
      download: el.find("input[name='download']").is ":checked"
      edit: el.find("input[name='edit']").is ":checked"
      manage: el.find("input[name='manage']").is ":checked"
    App.PermissionPreset.match elPermissions, @permissionPresets

  switchPresetForElement: (el, preset)->
    if preset?
      el.find(".ui-rights-role option[value='#{preset.name}']").select().attr "selected", true
      el.find(".ui-rights-role .ui-custom-select span").text preset.name
    else
      el.find(".ui-rights-role .ui-custom-select span").text "Angepasst"

  setPresetFor: (el, preset)->
    el.find("input[name='view']").attr("checked", preset.view).trigger "change"
    el.find("input[name='download']").attr("checked", preset.download).trigger "change"
    el.find("input[name='edit']").attr("checked", preset.edit).trigger "change"
    el.find("input[name='manage']").attr("checked", preset.manage).trigger "change"

  fetchPermissions: ->
    fetchData = 
      with: 
        users: true
        groups: true
        owners: true
    $.extend fetchData, {media_resource_ids: @mediaResourceIds} if @mediaResourceId?
    $.extend fetchData, {collection_id: @collection.id} if @collection?
    App.Permission.fetch fetchData, (permissions)=>
      @permissions = permissions
      do @render
      do @enableSaveButton

  loadPermissionsForMultipleResource: ->
    App.Permission.fetch
      collection_id: @collection.id
      with: 
        users: true
        groups: true
        owners: true
    , (permissions)=>
      debugger
      @permissions = permissions
      do @render
      do @enableSaveButton

  enableSaveButton: ->
    @saveButton.removeClass "disabled"
    @saveButton.removeAttr "disabled"

  getDataForRender: ->
    currentUserGroupIds = _.map(currentUser.groups, (group)-> group.id)
    currentUserGroups = _.filter(@permissions.groups, (group)-> _.include(currentUserGroupIds, group.id))
    otherUsers = _.filter(@permissions.users, (user)-> user.id != currentUser.id)
    for owner in _.filter(@permissions.owners, (user)-> user.id != currentUser.id)
      otherUsers = _.filter otherUsers, (user)-> user.id != owner.id
      otherUsers.unshift do =>
        mediaResourceIds = owner.media_resource_ids
        owner.view = mediaResourceIds
        owner.edit = mediaResourceIds
        owner.download = mediaResourceIds
        owner.manage = mediaResourceIds
        return owner
    otherGroups = _.filter(@permissions.groups, (group)-> not _.include(currentUserGroupIds, group.id))
    data = 
      you: @permissionsForRender @permissions.you, @mediaResourceIds, @permissions.owners
      presets: @permissionPresets
      public: @permissionsForRender @permissions.public, @mediaResourceIds, @permissions.owners
      mediaResourceIds: @mediaResourceIds
      otherUsers: @permissionsForRender _.sortBy(otherUsers, (user)-> user.name), @mediaResourceIds, @permissions.owners
      otherGroups: @permissionsForRender _.sortBy(otherGroups, (group)-> group.name), @mediaResourceIds, @permissions.owners
    $.extend data, {currentUserGroups:  @permissionsForRender(_.sortBy(currentUserGroups, (group)-> group.name), @mediaResourceIds, @permissions.owners)} if currentUserGroups.length
    return data

  ownersForRender: (owners, mediaResourceIds)->
    owners = _.map(@permissions.owners, (user)-> user.id)
    if _.isEqual(owners.sort(), mediaResourceIds.sort()) then true else if permission.view.length then "mixed" else false

  permissionsForRender: (permissions, mediaResourceIds, owners)->
    permissions = [permissions] unless permissions instanceof Array
    permissions = JSON.parse JSON.stringify permissions
    for permission in permissions
      permission.view = if _.isEqual(permission.view.sort(), mediaResourceIds.sort()) then true else if permission.view.length then "mixed" else false
      permission.download = if _.isEqual(permission.download.sort(), mediaResourceIds.sort()) then true else if permission.download.length then "mixed" else false
      permission.edit = if _.isEqual(permission.edit.sort(), mediaResourceIds.sort()) then true else if permission.edit.length then "mixed" else false
      permission.manage = if permission.manage? and _.isEqual(permission.manage.sort(), mediaResourceIds.sort()) then true else if permission.manage? and permission.manage.length then "mixed" else false
      owner = _.find owners, (subject)-> subject.id == permission.id
      if owner?
        if _.isEqual(owner.media_resource_ids.sort(), mediaResourceIds.sort()) 
          permission.ownership = true
        else
          permission.ownership = "mixed"
      else
        permission.ownership = false
    return permissions

  render: ->
    template = App.render "permissions/index", do @getDataForRender, {manageable: @manageable}
    @rightsContainer.replaceWith template
    @rightsContainer = template
    @otherGroupsContainer = template.find ".ui-rights-management-other-groups"
    @otherUsersContainer = template.find ".ui-rights-management-other-users"
    @currentUserGroupsContainer = template.find ".ui-rights-management-current-user-groups"
    @currentUserLine = template.find ".ui-rights-management-current-user tr"
    @addUserContainer = template.find "#addUser"
    @addGroupContainer = template.find "#addGroup"
    @publicPermissionsContainer = template.find ".ui-rights-management-public"
    do @setupaddUser if @addUserContainer.length
    do @setupAddGroup if @addGroupContainer.length

window.Permissions = Permissions

jQuery ->
  $("[data-open-permissions]").bind "click", (e)-> new Permissions $(e.currentTarget)