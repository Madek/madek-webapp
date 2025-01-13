const MediaEntryPermissions = require('../media-entry/permissions.js')
const BatchResourcePermissionsFactory = require('../shared/batch-resource-permissions-factory.js')

module.exports = BatchResourcePermissionsFactory(
  'BatchMediaEntryPermissions',
  MediaEntryPermissions
)
