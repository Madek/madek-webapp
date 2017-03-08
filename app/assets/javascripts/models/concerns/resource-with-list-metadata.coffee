f = require('active-lodash')
setUrlParams = require('../../lib/set-params-for-url.coffee')
parseUrl = require('url').parse
buildUrl = require('url').format
buildQuery = require('qs').stringify
parseQuery = require('qs').parse

module.exports =

  props:
    list_meta_data: 'object'

  loadListMetadata: (callback) ->

    currentQuery = parseQuery(
      parseUrl(window.location.toString()).query
    )

    url = setUrlParams(
      @url + '/list_meta_data',
      currentQuery
    )

    @_runRequest(
      {
        url: url
        json: true
      },
      (err, res, json) =>
        if err
          callback(err)
        else
          @set('list_meta_data', json)
          callback(err, res)
    )
