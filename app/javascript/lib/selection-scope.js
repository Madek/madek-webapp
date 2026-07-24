import { filter, includes } from 'lodash-es'

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
    return filter(selection, r => {
      return this.batchMetaDataResource(r) && includes(types, r.type)
    })
  },

  batchPermissionResources(selection, types) {
    return filter(selection, r => {
      return this.batchPermissionResource(r) && includes(types, r.type)
    })
  },

  batchTransferResponsibilityResources(selection, types) {
    return filter(selection, r => {
      return this.batchTransferResponsibilityResource(r) && includes(types, r.type)
    })
  },

  batchDestroyResources(selection, types) {
    return filter(selection, r => {
      return this.batchDestroyResource(r) && includes(types, r.type)
    })
  }
}

export default toExport
