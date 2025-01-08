const AppResource = require('./shared/app-resource.js')

module.exports = AppResource.extend({
  type: 'Person',
  props: {
    name: ['string']
  }
})
