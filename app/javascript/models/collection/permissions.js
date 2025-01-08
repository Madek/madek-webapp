/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const Collection = require('ampersand-rest-collection');
const AppResource = require('../shared/app-resource.coffee');
const ResourcePermissions = require('../shared/resource-permissions.coffee');
const User = require('../user.coffee');
const Group = require('../group.coffee');
const ApiClient = require('../api-client.coffee');

// Child Collections/Models (defined here because they are not needed anywhere else)

const CollectionPublicPermission = AppResource.extend({
  type: 'CollectionPublicPermission',
  props: {
    get_metadata_and_previews: ['trilean'],
    get_full_size: ['trilean']
  }});

const CollectionUserPermissions = Collection.extend({
  model: AppResource.extend({
    type: 'CollectionUserPermission',
    children: {
      subject: User
    },
    props: {
      get_metadata_and_previews: ['trilean', false, false],
      get_full_size: ['trilean', false, false],
      edit_metadata_and_relations: ['trilean', false, false],
      edit_permissions: ['trilean', false, false]
    }})});

const CollectionGroupPermissions = Collection.extend({
  type: 'CollectionGroupPermissions',
  model: AppResource.extend({
    type: 'CollectionGroupPermission',
    children: {
      subject: Group
    },
    props: {
      get_metadata_and_previews: ['trilean', false, false],
      get_full_size: ['trilean', false, false],
      edit_metadata_and_relations: ['trilean', false, false]
    }})});

const CollectionApiClientPermissions = Collection.extend({
  type: 'CollectionApiClientPermissions',
  model: AppResource.extend({
    type: 'CollectionApiClientPermission',
    children: {
      subject: ApiClient
    },
    props: {
      get_metadata_and_previews: ['trilean', false, false],
      get_full_size: ['trilean', false, false]
    }})});


module.exports = ResourcePermissions.extend({
  type: 'CollectionPermissions',

  children: { // public permission is just 1 subject, so not a collection!
    public_permission: CollectionPublicPermission
  },

  collections: {
    user_permissions: CollectionUserPermissions,
    group_permissions: CollectionGroupPermissions,
    api_client_permissions: CollectionApiClientPermissions
  },

  // custom serialize to match what rails expects
  serialize(data){
    return {collection: (AppResource.prototype.serialize.call(this, data))};
  }});
