const CollectionPermissions = require('../collection/permissions.js');
const BatchResourcePermissionsFactory = require('../shared/batch-resource-permissions-factory.js');

module.exports =
  BatchResourcePermissionsFactory('BatchCollectionPermissions', CollectionPermissions);
