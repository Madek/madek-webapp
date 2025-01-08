f = require('active-lodash')
AppCollection = require('./shared/app-collection.coffee')
MetaDatum = require('./meta-datum.coffee')

# `MetaDatum` is an object with subtypes (Models),
# this (polymorph) collection to contain any of them.
# If it has a parent resource, it can be saved back to the server.
# Because of polymorphism, we need to override `#model` and `#isModel`
subtypes = f.keys(MetaDatum)

module.exports = AppCollection.extend
  type: 'MetaData'

  # Create a new instance from object (e.g. `{type: 'MetaDatum::Text'}`):
  model: (attrs, options)->
    MetaDatumClass = MetaDatum[f.trimLeft(attrs.type, 'MetaDatum::')]
    throw new Error "No such type: #{attrs.type}!" unless MetaDatumClass
    return new MetaDatumClass(attrs, options)

  # Check if an instance is one the valid models:
  isModel: (model)->
    f.any f.map f.keys(MetaDatum), (subType)->
      model instanceof MetaDatum[subType]

  # Parse `Presenters::MetaData` into array of model objects:
  parse: (meta_data)->
    f.filter f.flatten f.map(meta_data.by_vocabulary, 'meta_data')

  # Save the collection to the parent resource (Concern `MetaDataUpdate`):
  save: (opts)->
    AppCollection::sync.call @, 'update', @, f.merge opts,
      url: @parent.url + '/meta_data'
      json: f.set({}, f.snakeCase(@parent.type), serializeForSave(@))

# helper:
serializeForSave = (list)->
  meta_data: f.object list.map (md)-> [md.meta_key.uuid, md.literal_values]
