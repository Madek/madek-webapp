AppResource = require('./app-resource.coffee')
MetaKey = require('./meta-key.coffee')

module.exports = AppResource.extend
  urlRoot: '/meta_data'
  props: # [type, required, default]
    values: ['array', true]
    literal_values: ['array', true]

  children:
    meta_key: MetaKey
