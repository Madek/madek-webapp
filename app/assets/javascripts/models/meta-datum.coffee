AppResource = require('./shared/app-resource.coffee')
MetaKey = require('./meta-key.coffee')

module.exports = AppResource.extend
  urlRoot: '/meta_data'
  props:
    values:
      type: 'array'
      required: true
    literal_values:
      type: 'array'
      required: true

  children:
    meta_key: MetaKey
