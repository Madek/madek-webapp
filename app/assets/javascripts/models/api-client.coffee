AppResource = require('./shared/app-resource.coffee')

module.exports = AppResource.extend
  props:
    login: ['string']
    description: ['string']

# TODO: derived name
