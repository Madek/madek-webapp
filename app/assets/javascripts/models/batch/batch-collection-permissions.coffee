CollectionPermissions = require('../collection/permissions.coffee')
BatchResourcePermissionsFactory = require('../shared/batch-resource-permissions-factory.coffee')

module.exports =
  BatchResourcePermissionsFactory('BatchCollectionPermissions', CollectionPermissions)
