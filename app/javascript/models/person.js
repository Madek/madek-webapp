const AppResource = require('./shared/app-resource.coffee');

module.exports = AppResource.extend({
  type: 'Person',
  props: {
    name: ['string']
  }});
