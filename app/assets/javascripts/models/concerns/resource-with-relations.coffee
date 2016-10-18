# Concern: ResourceWithRelations

f = require('active-lodash')
parseUrl = require('url').parse
buildUrl = require('url').format
buildParams = require('qs').stringify

module.exports =
  props:
    parent_collections: ['object']
    sibling_collections: ['object']
    # NOTE: Collections also have:
    # child_media_resources: ['object']

  # instance methods:
  fetchRelations: (type, callback)->
    validTypes = ['parent', 'sibling', 'child']
    throw new Error('Invalid Relations type!') unless f.include(validTypes, type)
    # NOTE: format: ['subpath_of_action', 'jsonPath.inside.presenter']
    #       last part of jsonpath is the key inside here…
    supportedRelations = {
      parent: ['relations', 'relations.parent_collections']
      sibling: ['relations', 'relations.sibling_collections']
      child: ['', 'child_media_resources']
    }
    [subPath, jsonPath] = supportedRelations[type]
    modelAttr = f.last(jsonPath.split('.'))

    return if f.present(@get(jsonPath)) # only fetch if missing

    sparseSpec = JSON.stringify(f.set({}, jsonPath, {}))

    relationsUrl = buildUrl(f.merge(parseUrl( @url + '/' + subPath),
      {search: buildParams(list: { page: 1, per_page: 2 }, ___sparse: sparseSpec)}))

    @_runRequest {
      url: relationsUrl
      json: true
    }, (err, res, json)=>
      if (err or res.statusCode >= 400)
        console.error('Error fetching relations!', err or json)
        return callback(err or json) if f.isFunction(callback)

      # update self with server response:
      data = f.get(json, jsonPath)
      @set(modelAttr, data) if f.present(data)
      callback(err, data) if f.isFunction(callback)
