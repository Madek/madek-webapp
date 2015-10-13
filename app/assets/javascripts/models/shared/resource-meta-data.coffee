Collection = require('ampersand-rest-collection')
AppResource = require('./app-resource.coffee')
f = require('../../lib/fun.coffee')
MetaDatum = require('../meta-datum.coffee')

module.exports = AppResource.extend
  type: 'ResourceMetaData'
  collections:
    list: Collection.extend
      type: 'MetaData'
      model: MetaDatum

  # custom save (batch update)
  save: (opts)->
    AppResource::save.call @, f.merge opts,
      url: @parent.url + '/meta_data'
      method: 'PUT'
      json:
        media_entry:
          meta_data: f.zipObject f.filter @serialize().list.map (md)->
            # TMP: no MetaDatum::Users (it's broken)!
            return if md.meta_key.value_type is 'MetaDatum::Users'
            [md.meta_key.uuid, md.literal_values]
