Collection = require('ampersand-rest-collection')
AppResource = require('../shared/app-resource.coffee')
ResourcePermissions = require('../shared/resource-permissions.coffee')
User = require('../user.coffee')
Group = require('../group.coffee')
ApiClient = require('../api-client.coffee')

# NOTE: 'trilean' type for usage in batch - can be true, false or mixed

# Child Collections/Models (defined here because they are not needed anywhere else)
MediaEntryPublicPermission = AppResource.extend
  type: 'MediaEntryPublicPermission'
  props:
    get_metadata_and_previews: ['trilean']
    get_full_size: ['trilean']

MediaEntryUserPermissions = Collection.extend
  model: AppResource.extend
    type: 'MediaEntryUserPermission'
    children:
      subject: User
    props:
      get_metadata_and_previews: ['trilean', no, off]
      get_full_size: ['trilean', no, off]
      edit_metadata: ['trilean', no, off]
      edit_permissions: ['trilean', no, off]

MediaEntryGroupPermissions = Collection.extend
  type: 'MediaEntryGroupPermissions'
  model: AppResource.extend
    type: 'MediaEntryGroupPermission'
    children:
      subject: Group
    props:
      get_metadata_and_previews: ['trilean', no, off]
      get_full_size: ['trilean', no, off]
      edit_metadata: ['trilean', no, off]

MediaEntryApiClientPermissions = Collection.extend
  type: 'MediaEntryApiClientPermissions'
  model: AppResource.extend
    type: 'MediaEntryApiClientPermission'
    children:
      subject: ApiClient
    props:
      get_metadata_and_previews: ['trilean', no, off]
      get_full_size: ['trilean', no, off]

module.exports = ResourcePermissions.extend
  type: 'MediaEntryPermissions'

  children: # public permission is just 1 subject, so not a collection!
    public_permission: MediaEntryPublicPermission

  collections:
    user_permissions: MediaEntryUserPermissions
    group_permissions: MediaEntryGroupPermissions
    api_client_permissions: MediaEntryApiClientPermissions

  # custom serialize to match what rails expects — used on this.save()
  serialize: (data)->
    {media_entry: (AppResource::serialize.call @, data)}
