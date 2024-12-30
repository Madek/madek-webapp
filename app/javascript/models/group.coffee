AppResource = require('./shared/app-resource.coffee')

module.exports = AppResource.extend
  type: 'Group'
  extraProperties: 'allow'
  props:
    name: ['string']
