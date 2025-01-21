import CollectionPermissions from '../collection/permissions.js'
import BatchResourcePermissionsFactory from '../shared/batch-resource-permissions-factory.js'

module.exports = BatchResourcePermissionsFactory(
  'BatchCollectionPermissions',
  CollectionPermissions
)
