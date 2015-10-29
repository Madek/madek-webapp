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

  parse: (meta_data)->
    f(meta_data.by_vocabulary).map('meta_data').flatten().filter().run()

  save: (opts)->
    # set options, format data, call to 'super':
    AppCollection::sync.call @, 'update', @, f.merge opts,
      url: @parent.url + '/meta_data'
      json:
        media_entry:
          meta_data: f.object @map (md)-> [md.meta_key.uuid, md.literal_values]
