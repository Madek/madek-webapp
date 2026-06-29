import AppResource from './shared/app-resource.js'

export default AppResource.extend({
  type: 'Person',
  props: {
    name: ['string']
  }
})
