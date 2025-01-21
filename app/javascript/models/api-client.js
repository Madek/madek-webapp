import AppResource from './shared/app-resource.js'

module.exports = AppResource.extend({
  type: 'ApiClient',
  props: {
    login: ['string'],
    description: ['string']
  }
})
