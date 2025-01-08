AppCollection = require('./shared/app-collection.coffee')
Collection = require('./collection.coffee')
PaginatedCollection = require('./shared/paginated-collection-factory.coffee')

Collections = AppCollection.extend
  type: 'Collections'
  model: Collection

Collections.Paginated = PaginatedCollection(Collections, jsonPath: 'resources')

module.exports = Collections
