Collection = require('ampersand-rest-collection')
AppResource = require('../shared/app-resource.coffee')
ResourcePermissions = require('../shared/resource-permissions.coffee')
User = require('../user.coffee')
Group = require('../group.coffee')
ApiClient = require('../api-client.coffee')

# Child Collections/Models (defined here because they are not needed anywhere else)

CollectionPublicPermission = AppResource.extend
  type: 'CollectionPublicPermission'
  props:
    get_metadata_and_previews: ['boolean']
    get_full_size: ['boolean']

CollectionUserPermissions = Collection.extend
  model: AppResource.extend
    type: 'CollectionUserPermission'
    children:
      subject: User
    props:
      get_metadata_and_previews: ['boolean', no, off]
      get_full_size: ['boolean', no, off]
      edit_metadata_and_relations: ['boolean', no, off]
      edit_permissions: ['boolean', no, off]

CollectionGroupPermissions = Collection.extend
  type: 'CollectionGroupPermissions'
  model: AppResource.extend
    type: 'CollectionGroupPermission'
    children:
      subject: Group
    props:
      get_metadata_and_previews: ['boolean', no, off]
      get_full_size: ['boolean', no, off]
      edit_metadata_and_relations: ['boolean', no, off]

CollectionApiClientPermissions = Collection.extend
  type: 'CollectionApiClientPermissions'
  model: AppResource.extend
    type: 'CollectionApiClientPermission'
    children:
      subject: ApiClient
    props:
      get_metadata_and_previews: ['boolean', no, off]
      get_full_size: ['boolean', no, off]


module.exports = ResourcePermissions.extend
  type: 'CollectionPermissions'

  children: # public permission is just 1 subject, so not a collection!
    public_permission: CollectionPublicPermission

  collections:
    user_permissions: CollectionUserPermissions
    group_permissions: CollectionGroupPermissions
    api_client_permissions: CollectionApiClientPermissions

  # custom serialize to match what rails expects
  serialize: (data)->
    {collection: (AppResource::serialize.call @, data)}
