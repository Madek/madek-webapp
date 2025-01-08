const AppResource = require('./shared/app-resource.js');

module.exports = AppResource.extend({
  type: 'MetaKey',
  props: {
    label: 'string',
    value_type: 'string'
  }
});
