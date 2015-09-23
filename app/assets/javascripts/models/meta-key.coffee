AppResource = require('./shared/app-resource.coffee')

module.exports = AppResource.extend
  type: 'MetaKey'
  props:
    label: 'string'
