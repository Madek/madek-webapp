import AppResource from './shared/app-resource.js'

export default AppResource.extend({
  type: 'Group',
  extraProperties: 'allow',
  props: {
    name: ['string']
  }
})
