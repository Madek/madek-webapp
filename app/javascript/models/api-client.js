import AppResource from './shared/app-resource.js'

export default AppResource.extend({
  type: 'ApiClient',
  props: {
    login: ['string'],
    description: ['string'],
    tooltip_text: { type: 'string', default: '', allowNull: true }
  }
})
