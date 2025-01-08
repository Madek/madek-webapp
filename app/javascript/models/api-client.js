const AppResource = require('./shared/app-resource.coffee');

module.exports = AppResource.extend({
  type: 'ApiClient',
  props: {
    login: ['string'],
    description: ['string']
  }});
