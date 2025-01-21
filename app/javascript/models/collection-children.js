/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import AppCollection from './shared/app-collection.js'
import Collection from './collection.js'
import MediaEntry from './media-entry.js'
import PaginatedCollection from './shared/paginated-collection-factory.js'

const CollectionChildren = AppCollection.extend({
  type: 'CollectionChildren',

  model(attributes, options) {
    if (attributes.type === 'MediaEntry') {
      return new MediaEntry(attributes, options)
    } else if (attributes.type === 'Collection') {
      return new Collection(attributes, options)
    } else {
      throw new Error(
        '[collection-children.js] Cannot find a model for ' + JSON.stringify(attributes)
      )
    }
  },

  isModel(model) {
    return model instanceof MediaEntry || model instanceof Collection
  },

  getBatchEditableItems() {
    return this.filter(item => item.isBatchEditable)
  },

  getBatchPermissionEditableItems() {
    return this.filter(item => item.permissions_editable)
  }
})

CollectionChildren.Paginated = PaginatedCollection(CollectionChildren, {
  jsonPath: 'child_media_resources.resources'
})

CollectionChildren.PaginatedClipboard = PaginatedCollection(CollectionChildren, {
  jsonPath: 'resources'
})

module.exports = CollectionChildren
