AppCollection = require('./shared/app-collection.coffee')
AppResource = require('./shared/app-resource.coffee')
Collection = require('./collection.coffee')
MediaEntry = require('./media-entry.coffee')
PaginatedCollection = require('./shared/paginated-collection-factory.coffee')


CollectionChildren = AppCollection.extend
  type: 'CollectionChildren'

  model: (attributes, options) ->
    if attributes.type == 'MediaEntry'
      return new MediaEntry(attributes, options)
    else if attributes.type == 'Collection'
      return new Collection(attributes, options)
    else
      throw new Error('[collection-children.coffee] Cannot find a model for ' + JSON.stringify(attributes))

  isModel: (model) ->
    return model instanceof MediaEntry || model instanceof Collection

  getBatchEditableItems: () ->
    @filter (item) -> item.isBatchEditable

  getBatchPermissionEditableItems: ()->
    @filter (item)-> item.permissions_editable


CollectionChildren.Paginated = PaginatedCollection(
  CollectionChildren, jsonPath: 'relations.child_media_resources.resources')

module.exports = CollectionChildren
