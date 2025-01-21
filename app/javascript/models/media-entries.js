/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import AppCollection from './shared/app-collection.js'
import MediaEntry from './media-entry.js'
import PaginatedCollection from './shared/paginated-collection-factory.js'

const MediaEntries = AppCollection.extend({
  type: 'MediaEntries',
  model: MediaEntry,

  // public methods:
  getBatchEditableItems() {
    return this.filter(item => item.isBatchEditable)
  },

  getBatchPermissionEditableItems() {
    return this.filter(item => item.permissions_editable)
  }
})

MediaEntries.Paginated = PaginatedCollection(MediaEntries, { jsonPath: 'resources' })

module.exports = MediaEntries
