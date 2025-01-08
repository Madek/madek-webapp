MediaEntryPermissions = require('../media-entry/permissions.coffee')
BatchResourcePermissionsFactory = require('../shared/batch-resource-permissions-factory.coffee')

module.exports =
  BatchResourcePermissionsFactory('BatchMediaEntryPermissions', MediaEntryPermissions)
