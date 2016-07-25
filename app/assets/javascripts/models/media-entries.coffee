AppCollection = require('./shared/app-collection.coffee')
MediaEntry = require('./media-entry.coffee')
PaginatedCollection = require('./shared/paginated-collection-factory.coffee')

MediaEntries = AppCollection.extend
  type: 'MediaEntries'
  model: MediaEntry

  # public methods:
  getBatchEditableItems: ()->
    @filter (item)-> item.isBatchEditable

MediaEntries.Paginated = PaginatedCollection(MediaEntries, jsonPath: 'resources')

module.exports = MediaEntries
