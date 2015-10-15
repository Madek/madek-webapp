Collection = require('ampersand-rest-collection')
RailsResource = require('./rails-resource-mixin.coffee')

# Base class for Restful Application Resource Collection
module.exports = Collection.extend RailsResource,
  type: 'AppCollectionBase'
