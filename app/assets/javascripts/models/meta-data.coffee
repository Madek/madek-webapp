f = require('active-lodash')
AppCollection = require('./shared/app-collection.coffee')
MetaDatum = require('./meta-datum.coffee')

module.exports = AppCollection.extend
  type: 'MetaData'

  model: (attrs, options)->
    MetaDatumClass = MetaDatum[f.trimLeft(attrs.type, 'MetaDatum::')]
    unless MetaDatumClass
      throw new Error "Model: ResourceMetaData: No such type: #{attrs.type}!"
    new MetaDatumClass(attrs, options)

  isModel: (model)->
    f.any f.filter f.map f.keys(MetaDatum), (subType)->
      model instanceof MetaDatum[subType]

  parse: (data)->
    meta_data = data.by_vocabulary
    f.filter f.flatten f.map f.keys(meta_data), (key)->
      meta_data[key].meta_data

  save: (opts)->
    # set options, format data, call to 'super':
    AppCollection::sync.call @, 'update', @, f.merge opts,
      url: @parent.url + '/meta_data'
      json:
        media_entry:
          meta_data: f.zipObject f.filter @map (md)->
            # TMP: no MetaDatum::Users (it's broken)!
            return if md.meta_key.value_type is 'MetaDatum::Users'
            [md.meta_key.uuid, md.literal_values]
