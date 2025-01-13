/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const f = require('lodash')

const toExport = {
  batchMetaDataResource(resource) {
    return resource.editable && !resource.invalid_meta_data
  },

  batchPermissionResource(resource) {
    return resource.permissions_editable
  },

  batchTransferResponsibilityResource(resource) {
    return resource.responsibility_transferable
  },

  batchDestroyResource(resource) {
    return resource.destroyable
  },

  batchMetaDataResources(selection, types) {
    return f.filter(selection, r => {
      return this.batchMetaDataResource(r) && f.includes(types, r.type)
    })
  },

  batchPermissionResources(selection, types) {
    return f.filter(selection, r => {
      return this.batchPermissionResource(r) && f.includes(types, r.type)
    })
  },

  batchTransferResponsibilityResources(selection, types) {
    return f.filter(selection, r => {
      return this.batchTransferResponsibilityResource(r) && f.includes(types, r.type)
    })
  },

  batchDestroyResources(selection, types) {
    return f.filter(selection, r => {
      return this.batchDestroyResource(r) && f.includes(types, r.type)
    })
  }
}

module.exports = toExport
