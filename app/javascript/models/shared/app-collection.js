import { present } from '../../lib/present'
import BaseCollection from './base-collection.js'
import RailsResource from './rails-resource-mixin.js'

// Base class for RESTful application resource collections
const AppCollection = BaseCollection.extend(RailsResource, {
  type: 'AppCollection',
  mainIndex: ['url'],
  indexes: ['uuid'],

  has(index) {
    return present(this.get(index))
  }
})

export default AppCollection
