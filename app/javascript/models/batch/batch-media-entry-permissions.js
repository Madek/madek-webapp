import MediaEntryPermissions from '../media-entry/permissions.js'
import BatchResourcePermissionsFactory from '../shared/batch-resource-permissions-factory.js'

module.exports = BatchResourcePermissionsFactory(
  'BatchMediaEntryPermissions',
  MediaEntryPermissions
)
