# This is a (simple) factory, used by ModelCollections that can paginate.

f = require('active-lodash')
State = require('ampersand-state')
Collection = require('ampersand-rest-collection')
AppCollection = require('./app-collection.coffee')

xhr = require('xhr')
setUrlParams = require('../../lib/set-params-for-url.coffee')
getOrThrow = (obj, key)->
  val = f.get(obj, key)
  if !f.present(val) then throw new Error('Missing config! ' + key)
  val


module.exports = (collectionClass, {jsonPath})->
  State.extend
    collections:
      resources: collectionClass

    props:
      url: ['object']
      perPage: ['number']
      firstPage: ['number']
      currentPage: ['number']
      totalCount: ['number']

    derived:
      # make it behave more like a normal collection (for controllers)
      models: { deps: ['resources'], fn: ()-> @resources.models }
      length: { deps: ['resources'], fn: ()-> @resources.length }

      totalPages:
        deps: ['totalCount', 'perPage']
        fn: ()-> Math.ceil(@totalCount / @perPage)

      hasNext:
        deps: ['currentPage', 'totalPages']
        fn: ()-> @totalPages > @currentPage

      # return resources by pages (for rendering)
      # [{ resources: [{…}, …], pagination: { page: 1, … } }, …]
      pages:
        deps: ['currentPage', 'resources', 'totalPages', 'totalCount', 'perPage']
        fn: ()->
          paginationBase = { totalPages: @totalPages, totalCount: @totalCount}

          f(@resources.models)
            .chunk(@perPage)
            .map((resources, n) => {
              url: setUrlParams(@url, {list: {page: (@firstPage + n)}})
              resources: resources
              pagination: f.extend(
                paginationBase, { page: (@firstPage + n) }) })
            .value()

    initialize: (data)->
      # TODO: cleanup pagination backend, only those props are needed:
      @set({
        url: getOrThrow(data, 'config.for_url')
        perPage: getOrThrow(data, 'config.per_page'),
        firstPage: getOrThrow(data, 'config.page'),
        currentPage: getOrThrow(data, 'config.page'),
        totalCount: getOrThrow(data, 'pagination.total_count'),
        totalPages: getOrThrow(data, 'pagination.total_pages')
      })
      # listen to child collections
      if @resources && f.isFunction(@resources.on)
        @resources?.on('change add remove reset', (e)=> @trigger('change'))

    # instance methods:

    # fetches the next page of `resources`
    fetchNext: (callback)->
      throw new Error('Callback missing!') if (!f.isFunction(callback))
      return callback(null) unless @currentPage

      path = @url.pathname
      if path.indexOf('/relations/children') > 0 or path.indexOf('/relations/siblings') > 0 or path.indexOf('/relations/parents') > 0
        jsonPath = 'relation_resources.resources'

      if path.indexOf('/vocabulary') == 0 and path.indexOf('/contents') > 0
        jsonPath = 'resources.resources'

      nextPage = (@currentPage + 1)
      nextUrl = setUrlParams(
        @url,
        {list: {page: nextPage}},
        {___sparse: JSON.stringify(f.set({}, jsonPath, {}))})

      return xhr.get(
        {url: nextUrl, json: true },
        (err, res, body) => (
          if err || res.statusCode > 400
            return callback(err || body)

          @resources.add(f.get(body, jsonPath))
          @set({currentPage: nextPage})
          callback(null)
      ))

    fetchAllResourceIds: (callback)->
      throw new Error('Callback missing!') if (!f.isFunction(callback))

      path = @url.pathname
      if path.indexOf('/relations/children') > 0 or path.indexOf('/relations/siblings') > 0 or path.indexOf('/relations/parents') > 0
        jsonPath = 'relation_resources.resources'

      if path.indexOf('/vocabulary') == 0 and path.indexOf('/contents') > 0
        jsonPath = 'resources.resources'

      nextUrl = setUrlParams(
        @url,
        {list: {page: 1, per_page: @totalCount}},
        {___sparse: JSON.stringify(f.set({}, jsonPath, [{uuid: {}, type: {}}]))})

      return xhr.get(
        {url: nextUrl, json: true },
        (err, res, body) -> (
          if err || res.statusCode > 400
            return callback({result: 'error'})

          callback({
            result: 'success',
            data: f.get(body, jsonPath)
          })
      ))
