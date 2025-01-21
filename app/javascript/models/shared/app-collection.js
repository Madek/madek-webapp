import f from 'active-lodash'
import Collection from 'ampersand-rest-collection'
import RailsResource from './rails-resource-mixin.js'

// Base class for Restful Application Resource Collection
module.exports = Collection.extend(RailsResource, {
  type: 'AppCollection',
  mainIndex: ['url'],
  indexes: ['uuid'],

  // instance methods:
  has(index) {
    return f.present(this.get(index))
  }
})
