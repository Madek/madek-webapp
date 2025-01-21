import AppResource from './shared/app-resource.js'

module.exports = AppResource.extend({
  type: 'Group',
  extraProperties: 'allow',
  props: {
    name: ['string']
  }
})
