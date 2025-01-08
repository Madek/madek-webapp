const CollectionPermissions = require('../collection/permissions.coffee');
const BatchResourcePermissionsFactory = require('../shared/batch-resource-permissions-factory.coffee');

module.exports =
  BatchResourcePermissionsFactory('BatchCollectionPermissions', CollectionPermissions);
