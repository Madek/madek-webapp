AppResource = require('./app-resource.coffee')
MetaData = require('../meta-data.coffee')
f = require('active-lodash')
MetaDatum = require('../meta-datum.coffee')

module.exports = AppResource.extend
  collections:
    meta_data: MetaData

  parse: (data)->
    @set('meta_data', new MetaData(data.meta_data, parse: true))


  # custom save (batch update)
  save: (opts)->
    AppResource::save.call @, f.merge opts,
      url: @parent.url + '/meta_data'
      method: 'PUT'
      json:
        media_entry:
          meta_data: f.zipObject f.filter @serialize().meta_data.map (md)->
            # TMP: no MetaDatum::Users (it's broken)!
            #      <https://www.pivotaltracker.com/story/show/104716282>
            return if md.meta_key.value_type is 'MetaDatum::Users'
            [md.meta_key.uuid, md.literal_values]
