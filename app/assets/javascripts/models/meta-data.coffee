Collection = require('ampersand-rest-collection')
AppResource = require('./shared/app-resource.coffee')

module.exports = AppResource.extend
  type: 'ResourceMetaData'

  children:
    Vocabulary: Vocabulary

  collections:
    meta_data: Collection.extend
      type: 'MetaData'
      model: MetaDatum
