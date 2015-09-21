AppResource = require('./shared/app-resource.coffee')

module.exports = AppResource.extend
  props:
    name: ['string']
