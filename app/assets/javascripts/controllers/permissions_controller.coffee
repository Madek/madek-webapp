###

Permissions

###

class Permissions

  constructor: (el)->
    @manageable = el.data "manageable"
    @dialog = App.render "permissions/dialog", {title: el.data "title"}, {manageable: @manageable}
    @saveButton = @dialog.find "button[type='submit']"
    @rightsContainer = @dialog.find ".ui-rights-management"
    do @delegateEvents
    App.modal @dialog
    App.PermissionPreset.fetch null, (presets)=>
      @permissionPresets = presets

      if el.data "media-resource-id"
        @mediaResourceIds = [el.data("media-resource-id")]
        @loadForSingleMediaResource el.data "media-resource-id"

  delegateEvents: ->
    @dialog.on "change", ".ui-rights-check input", @onChangePermission
    @dialog.on "change", ".ui-rights-role select", @onChangePreset

  onChangePreset: (e)=>
    select = $(e.currentTarget)
    option = select.find("option:selected")
    el = $(e.currentTarget).closest "tr"
    @setPresetFor el, option.data "preset"

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
      el.find(".ui-rights-role select").trigger("change")
    else
      el.find(".ui-rights-role .ui-custom-select span").text "Angepasst"

  setPresetFor: (el, preset)->
    el.find("input[name='view']").attr "checked", preset.view
    el.find("input[name='download']").attr "checked", preset.download
    el.find("input[name='edit']").attr "checked", preset.edit
    el.find("input[name='manage']").attr "checked", preset.manage

  loadForSingleMediaResource: (id)->
    App.Permission.fetch 
      media_resource_ids: [id]
      with: 
        users: true
        groups: true
        owners: true
    , (permissions)=>
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
      otherUsers.unshift do =>
        mediaResourceIds = owner.media_resource_ids
        owner.view = mediaResourceIds
        owner.edit = mediaResourceIds
        owner.download = mediaResourceIds
        owner.manage = mediaResourceIds
        return owner
    otherGroups = _.filter(@permissions.groups, (group)-> not _.include(currentUserGroupIds, group.id))
    data = 
      you: @permissionsForRender @permissions.you, @mediaResourceIds
      presets: @permissionPresets
      public: @permissionsForRender @permissions.public, @mediaResourceIds
      ownerIds: _.map(@permissions.owners, (user)-> user.id)
      mediaResourceIds: @mediaResourceIds
      otherUsers: @permissionsForRender _.sortBy(otherUsers, (user)-> user.name), @mediaResourceIds
      otherGroups: @permissionsForRender _.sortBy(otherGroups, (group)-> group.name), @mediaResourceIds
    $.extend data, {currentUserGroups:  @permissionsForRender(_.sortBy(currentUserGroups, (group)-> group.name),@mediaResourceIds)} if currentUserGroups.length
    return data

  permissionsForRender: (permissions, mediaResourceIds)->
    permissions = [permissions] unless permissions instanceof Array
    permissions = JSON.parse JSON.stringify permissions
    for permission in permissions
      permission.view = if _.isEqual(permission.view.sort(), mediaResourceIds.sort()) then true else if permission.view.length then "mixed" else false
      permission.download = if _.isEqual(permission.download.sort(), mediaResourceIds.sort()) then true else if permission.download.length then "mixed" else false
      permission.edit = if _.isEqual(permission.edit.sort(), mediaResourceIds.sort()) then true else if permission.edit.length then "mixed" else false
      permission.manage = if permission.manage? and _.isEqual(permission.manage.sort(), mediaResourceIds.sort()) then true else if permission.manage? and permission.manage.length then "mixed" else false
    return permissions

  render: ->
    template = App.render "permissions/index", do @getDataForRender, {manageable: @manageable}
    template.addClass "with-ownership"
    @rightsContainer.replaceWith template

window.Permissions = Permissions

jQuery ->
  $("[data-open-permissions]").bind "click", (e)-> new Permissions $(e.currentTarget)