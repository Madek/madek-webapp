AppCollection = require('./shared/app-collection.coffee')
Collections = require('./collection.coffee')
PaginatedCollection = require('./shared/paginated-collection-factory.coffee')

Collections = AppCollection.extend
  type: 'Collections'
  model: Collections

Collections.Paginated = PaginatedCollection(Collections, jsonPath: 'resources')

module.exports = Collections
