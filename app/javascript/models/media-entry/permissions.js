/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Collection = require('ampersand-rest-collection')
const AppResource = require('../shared/app-resource.js')
const ResourcePermissions = require('../shared/resource-permissions.js')
const User = require('../user.js')
const Group = require('../group.js')
const ApiClient = require('../api-client.js')

// NOTE: 'trilean' type for usage in batch - can be true, false or mixed

// Child Collections/Models (defined here because they are not needed anywhere else)
const MediaEntryPublicPermission = AppResource.extend({
  type: 'MediaEntryPublicPermission',
  props: {
    get_metadata_and_previews: ['trilean'],
    get_full_size: ['trilean']
  }
})

const MediaEntryUserPermissions = Collection.extend({
  model: AppResource.extend({
    type: 'MediaEntryUserPermission',
    children: {
      subject: User
    },
    props: {
      get_metadata_and_previews: ['trilean', false, false],
      get_full_size: ['trilean', false, false],
      edit_metadata: ['trilean', false, false],
      edit_permissions: ['trilean', false, false]
    }
  })
})

const MediaEntryGroupPermissions = Collection.extend({
  type: 'MediaEntryGroupPermissions',
  model: AppResource.extend({
    type: 'MediaEntryGroupPermission',
    children: {
      subject: Group
    },
    props: {
      get_metadata_and_previews: ['trilean', false, false],
      get_full_size: ['trilean', false, false],
      edit_metadata: ['trilean', false, false]
    }
  })
})

const MediaEntryApiClientPermissions = Collection.extend({
  type: 'MediaEntryApiClientPermissions',
  model: AppResource.extend({
    type: 'MediaEntryApiClientPermission',
    children: {
      subject: ApiClient
    },
    props: {
      get_metadata_and_previews: ['trilean', false, false],
      get_full_size: ['trilean', false, false]
    }
  })
})

module.exports = ResourcePermissions.extend({
  type: 'MediaEntryPermissions',

  children: {
    // public permission is just 1 subject, so not a collection!
    public_permission: MediaEntryPublicPermission
  },

  collections: {
    user_permissions: MediaEntryUserPermissions,
    group_permissions: MediaEntryGroupPermissions,
    api_client_permissions: MediaEntryApiClientPermissions
  },

  // custom serialize to match what rails expects — used on this.save()
  serialize(data) {
    return { media_entry: AppResource.prototype.serialize.call(this, data) }
  }
})
