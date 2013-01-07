###

Permissions

###

class Permissions

  constructor: (el)->
    dialog = App.render "permissions/dialog"
    @saveButton = dialog.find "button[type='submit']"
    @rightsContainer = dialog.find ".ui-rights-management"
    App.modal dialog
    App.PermissionPreset.fetch null, (presets)=>
      @permissionPresets = presets

      if el.data "media-resource-id"
        @mediaResourceIds = [el.data("media-resource-id")]
        @loadForSingleMediaResource el.data "media-resource-id"

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

  render: ->
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
      you: @permissions.you
      presets: @permissionPresets
      public: @permissions.public
      ownerIds: _.map(@permissions.owners, (user)-> user.id)
      mediaResourceIds: @mediaResourceIds
    $.extend data, {currentUserGroups: currentUserGroups} if currentUserGroups.length
    $.extend data, {otherUsers: otherUsers}
    $.extend data, {otherGroups: otherGroups}
    template = App.render "permissions/index", data
    template.addClass "with-ownership"
    @rightsContainer.replaceWith template

window.Permissions = Permissions

jQuery ->
  $("[data-open-permissions]").bind "click", (e)-> new Permissions $(e.currentTarget)