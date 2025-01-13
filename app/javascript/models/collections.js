const AppCollection = require('./shared/app-collection.js')
const Collection = require('./collection.js')
const PaginatedCollection = require('./shared/paginated-collection-factory.js')

const Collections = AppCollection.extend({
  type: 'Collections',
  model: Collection
})

Collections.Paginated = PaginatedCollection(Collections, { jsonPath: 'resources' })

module.exports = Collections
