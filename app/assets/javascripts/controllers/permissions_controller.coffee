###

Permissions

###

class PermissionsController

  constructor: (options)->
    el = if options.dialog? then options.dialog else if options.inline? then options.inline
    @manageable = el.data "manageable"
    @redirectUrl = el.data "redirect-url"
    if options.dialog?
      @showDialog el
    else if options.inline?
      @showInline el
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
      else if el.data("collection-id")?
        @collection = new App.Collection
          id: el.data("collection-id")
        @collection.get =>
          @mediaResourceIds = @collection.ids
          do @fetchPermissions

  delegateEvents: ->
    @el.on "change", ".ui-rights-check-label.mixed input", @changeMixedValue
    @el.on "change", ".ui-rights-check input", @onChangePermission
    @el.on "change", ".ui-rights-role select", (e)=> @onChangePreset $(e.currentTarget)
    @el.on "click", ".ui-rights-role select option", (e)=> @onChangePreset $(e.currentTarget).closest "select"
    @el.on "click", ".ui-rights-remove", (e)=> $(e.currentTarget).closest("tr").remove()
    @el.on "change", ".ui-rights-owner input", (e)=> @changeOwnerTo $(e.currentTarget).closest "tr"
    @el.on "change", ".ui-rights-management-public .ui-rights-check input", @onChangePublicPermission
    @form.on "submit", @onSubmit
    @form.on "keypress", "input", (e)=> 
      if e.keyCode == 13
        e.preventDefault()
        return false

  changeMixedValue: (e)=>
    input = $(e.currentTarget)
    mixedIndicator = input.next(".ui-right-mixed-values")
    label = input.closest "label"
    if input.val() is "mixed" # switch to none
      mixedIndicator.hide()
      input.val("none")
      input.attr "checked", false
      label.addClass "overwrite"
      e.preventDefault()
      return false
    else if input.val() is "none"  # switch to all
      mixedIndicator.hide()
      input.val("all")
      input.attr "checked", true
      label.addClass "overwrite"
    else if input.val() is "all" # switch to mixed
      mixedIndicator.show()
      input.val("mixed")
      input.attr "checked", false
      label.removeClass "overwrite"

  onSubmit: (e)=>
    do e.preventDefault
    userPermissions = _.map @usersContainer.find("tr"), (line)=> @getPermissionDataFromLine $(line)
    groupPermissions = _.map @groupsContainer.find("tr"), (line)=> @getPermissionDataFromLine $(line)
    publicPermissions = _.map @publicPermissionsContainer.find("tr"), (line)=> @getPermissionDataFromLine $(line)
    ownerLine = @rightsContainer.find(".ui-rights-owner input:checked").closest "tr"
    owner = if ownerLine.length then ownerLine.data("id") else undefined
    if @el.is ".ui-modal"
      do @el.remove 
    else
      @saveButton.addClass "disabled"
      do App.BrowserLoadingIndicator.start
    App.Permission.storeMultiple
      users: userPermissions
      groups: groupPermissions
      public: publicPermissions[0]
      owner: owner
    , @mediaResourceIds, (response)=> 
      if @redirectUrl?
        window.location = @redirectUrl
      else
        document.location.reload true
    return false

  getPermissionDataFromLine: (line)->
    id: line.data "id"
    view: @getPermission "view", line
    download: @getPermission "download", line
    edit: @getPermission "edit", line
    manage: @getPermission "manage", line

  getPermission: (name, line)-> 
    input = line.find "input[name='#{name}']"
    if input.is ":checked"
      true
    else if input.val() is "mixed"
      undefined
    else
      false

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
      currentUserOwnership: @permissionsForRender(@permissions.you, @mediaResourceIds, @permissions.owners)[0].ownership
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
      currentUserOwnership: @permissionsForRender(@permissions.you, @mediaResourceIds, @permissions.owners)[0].ownership

  showDialog: (el)=>
    title = if el.data("media-resource-id") then "'#{el.data("title")}'" else if el.data("collection") then "für #{el.data("collection").count} ausgewählte Inhalte"
    @el = App.render "permissions/dialog", {title: title}, {manageable: @manageable}
    @saveButton = @el.find "button[type='submit']"
    @form = @el.children "form"
    @rightsContainer = @el.find ".ui-rights-management"
    new App.Modal @el

  showInline: (el)->
    @el = el
    @saveButton = @el.find ".primary-button"
    @form = @el
    @rightsContainer = @el.find ".ui-rights-management"

  setupAddUser: ->
    setup = =>
      input = @addUserContainer.find("input")
      input.autocomplete
        appendTo: @el
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
          input.val("").focus()
          return false
      input.autocomplete("widget").addClass("narrow")
    # setup if dialog is visible (possible time shift because the bootstrap modal)
    if @el.is ":visible" then do setup else @el.one "shown", => do setup

  setupAddGroup: ->
    setup = =>
      input = @addGroupContainer.find("input")
      input.autocomplete
        appendTo: @el
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
          input.val("").focus()
          return false
      input.autocomplete("widget").addClass("wide")
      input.data("autocomplete")._renderItem = (ul, item)->
        listItem = $("<li title='#{item.label}'></li>")
          .data("item.autocomplete", item)
          .append("<a>#{item.label}</a>")
          .appendTo(ul);
        return listItem

    # setup if dialog is visible (possible time shift because the bootstrap modal)
    if @el.is ":visible" then do setup else @el.one "shown", => do setup

  addPermissionForSubject: (subject) =>
    if @rightsContainer.find("[data-id='#{subject.id}'][data-name='#{subject.name}']").length
      return true 
    line = App.render "permissions/line", 
      id: subject.id
      name: subject.name
      view: true
      download: false
      edit: false
      manage: false
      ownership: false
      type: if (subject instanceof App.User) then "userpermission" else if  (subject instanceof App.Group) then "grouppermission" 
      isCurrentUserGroup: if (subject instanceof App.Group) and  _.include(_.map(currentUser.groups, (group)-> group.id) ,subject.id) then true else false
    ,
      presets: @permissionPresets
      manageable: @manageable
      currentUserOwnership: @permissionsForRender(@permissions.you, @mediaResourceIds, @permissions.owners)[0].ownership
    target = if subject instanceof App.User
      @usersContainer.find("tbody")
    else if subject instanceof App.Group
      @groupsContainer.find("tbody")
    target.append line

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

  switchPresetForElement: (line, preset)->
    if line.find(".ui-rights-check-label.mixed").length and not line.find(".ui-rights-check-label.mixed").hasClass "overwrite"
      line.find(".ui-rights-role .ui-custom-select span").text "Gemischte Werte"
    else if preset?
      line.find(".ui-rights-role option[value='#{preset.name}']").select().attr "selected", true
      line.find(".ui-rights-role .ui-custom-select span").text preset.name
    else
      line.find(".ui-rights-role .ui-custom-select span").text "Angepasst"

  setPresetFor: (line, preset)->
    if line.find(".ui-rights-check-label.mixed").length
      line.find("input[name='view']").val if preset.view then "none" else "mixed"
      line.find("input[name='download']").val if preset.download then "none" else "mixed"
      line.find("input[name='edit']").val if preset.edit then "none" else "mixed"
      line.find("input[name='manage']").val if preset.manage then "none" else "mixed"
    line.find("input[name='view']").attr("checked", preset.view).trigger "change"
    line.find("input[name='download']").attr("checked", preset.download).trigger "change"
    line.find("input[name='edit']").attr("checked", preset.edit).trigger "change"
    line.find("input[name='manage']").attr("checked", preset.manage).trigger "change"

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
    _.each @permissions.groups , (g)-> g.isCurrentUserGroup = _.include(currentUserGroupIds,g.id)
    _.each @permissions.groups , (g)-> g.type = "grouppermission"
    _.each @permissions.users, (g)-> g.isUserpermission = true
    users = @permissions.users
    _.each users, (u)-> u.isCurrentUser = (u.id is currentUser.id)
    for owner in _.filter(@permissions.owners, (user)-> user.id != currentUser.id)
      users = _.filter users, (user)-> user.id != owner.id
      users.unshift do =>
        mediaResourceIds = owner.media_resource_ids
        owner.view = mediaResourceIds
        owner.edit = mediaResourceIds
        owner.download = mediaResourceIds
        owner.manage = mediaResourceIds
        return owner
    data = 
      currentUserOwnership: @permissionsForRender(@permissions.you, @mediaResourceIds, @permissions.owners)[0].ownership
      presets: @permissionPresets
      public: @permissionsForRender @permissions.public, @mediaResourceIds, @permissions.owners
      mediaResourceIds: @mediaResourceIds
      users: @permissionsForRender _.sortBy(users, (user)-> user.name), @mediaResourceIds, @permissions.owners
      groups: @permissionsForRender _.sortBy(@permissions.groups, (group)-> group.name), @mediaResourceIds, @permissions.owners
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
    @groupsContainer = template.find ".ui-rights-management-groups"
    @usersContainer = template.find ".ui-rights-management-users"
    @addUserContainer = template.find "#addUser"
    @addGroupContainer = template.find "#addGroup"
    @publicPermissionsContainer = template.find ".ui-rights-management-public"
    do @setupAddUser if @addUserContainer.length
    do @setupAddGroup if @addGroupContainer.length
    do @setInitalMixedValuesLabels

  setInitalMixedValuesLabels: ->
    for mixedLabel in @rightsContainer.find(".ui-rights-check-label.mixed")
      mixedLabel = $(mixedLabel)
      line = mixedLabel.closest "tr"
      @switchPresetForElement line, @getPresetForElement line

window.App.PermissionsController = PermissionsController

jQuery ->
  $(document).on "click", "[data-open-permissions]", (e)-> new PermissionsController
    dialog: $(e.currentTarget)
