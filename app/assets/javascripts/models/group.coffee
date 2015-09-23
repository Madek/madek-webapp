AppResource = require('./shared/app-resource.coffee')

module.exports = AppResource.extend
  type: 'Group'
  props:
    name: ['string']
