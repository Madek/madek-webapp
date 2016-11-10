f = require('lodash')

toExport =

  batchMetaDataResource: (resource) ->
    resource.editable and not resource.invalid_meta_data

  batchPermissionResource: (resource) ->
    resource.permissions_editable

  batchMetaDataResources: (selection, types) ->
    f.filter selection.selection, (r) =>
      @batchMetaDataResource(r) && f.includes(types, r.type)


  batchPermissionResources: (selection, types) ->
    f.filter selection.selection, (r) =>
      @batchPermissionResource(r) && f.includes(types, r.type)


module.exports = toExport
