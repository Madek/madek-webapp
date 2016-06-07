# Concern: ResourceWithRelations

f = require('active-lodash')
parseUrl = require('url').parse
buildUrl = require('url').format
buildParams = require('qs').stringify

module.exports =
  props:
    parent_media_resources: ['object']
    sibling_media_resources: ['object']
    # NOTE: Collections also have:
    # child_media_resources: ['object']

  # instance methods:
  fetchRelations: (type, callback)->
    validTypes = ['parent', 'sibling', 'child']
    throw new Error('Invalid Relations type!') unless f.include(validTypes, type)
    relType = type + '_media_resources'

    return if f.present(@get(relType)) # only fetch if missing

    # TODO: configure pagination/limits
    sparseSpec = '{"relations":{"' + relType + '":{}}}'

    relationsUrl = buildUrl(f.merge(parseUrl(@url),
      {search: buildParams(list: { page: 1, per_page: 2 }, ___sparse: sparseSpec)}))

    @_runRequest {
      url: relationsUrl
      json: true
    }, (err, res, data)=>
      if (err or res.statusCode >= 400)
        console.error('Error fetching relations!', err or data)
        return callback(err or data) if f.isFunction(callback)

      # update self with server response:
      data = f.get(data, ['relations', relType])
      @set(relType, data) if f.present(data)
      callback(err, data) if f.isFunction(callback)
