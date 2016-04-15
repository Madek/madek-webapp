f = require('active-lodash')
Collection = require('ampersand-rest-collection')
RailsResource = require('./rails-resource-mixin.coffee')

# Base class for Restful Application Resource Collection
module.exports = Collection.extend RailsResource,
  type: 'AppCollectionBase'
  mainIndex: ['url']
  indexes: ['uuid']

  # instance methods:
  has: (index)-> f.present(@get(index))
