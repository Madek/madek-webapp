import AppCollection from './shared/app-collection.js'
import Collection from './collection.js'
import PaginatedCollection from './shared/paginated-collection-factory.js'

const Collections = AppCollection.extend({
  type: 'Collections',
  model: Collection
})

Collections.Paginated = PaginatedCollection(Collections, { jsonPath: 'resources' })

module.exports = Collections
