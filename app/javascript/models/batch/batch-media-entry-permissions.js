const MediaEntryPermissions = require('../media-entry/permissions.coffee');
const BatchResourcePermissionsFactory = require('../shared/batch-resource-permissions-factory.coffee');

module.exports =
  BatchResourcePermissionsFactory('BatchMediaEntryPermissions', MediaEntryPermissions);
