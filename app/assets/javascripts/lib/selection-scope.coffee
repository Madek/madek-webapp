f = require('lodash')

toExport =

  batchMetaDataResource: (resource) ->
    resource.editable and not resource.invalid_meta_data

  batchPermissionResource: (resource) ->
    resource.permissions_editable

  batchTransferResponsibilityResource: (resource) ->
    resource.responsibility_transferable

  batchMetaDataResources: (selection, types) ->
    f.filter selection.selection, (r) =>
      @batchMetaDataResource(r) && f.includes(types, r.type)

  batchPermissionResources: (selection, types) ->
    f.filter selection.selection, (r) =>
      @batchPermissionResource(r) && f.includes(types, r.type)

  batchTransferResponsibilityResources: (selection, types) ->
    f.filter selection.selection, (r) =>
      @batchTransferResponsibilityResource(r) && f.includes(types, r.type)


module.exports = toExport
