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
      jobQueue: ['array']
      requestId: ['number']

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
        totalPages: getOrThrow(data, 'pagination.total_pages'),
        requestId: Math.random()
        jobQueue: []
      })
      # listen to child collections
      if @resources && f.isFunction(@resources.on)
        @resources?.on('change add remove reset', (e)=> @trigger('change'))

    # instance methods:

    clearPages: (url) ->
      @set({
        currentPage: 0,
        url: url,
        requestId: Math.random()
      })
      @resources.set([])

    # fetches the next page of `resources`
    fetchNext: (fetchListData, callback)->
      throw new Error('Callback missing!') if (!f.isFunction(callback))
      return callback(null) if (not @currentPage) && @currentPage != 0

      path = @url.pathname
      if path.indexOf('/relations/children') > 0 or path.indexOf('/relations/siblings') > 0 or path.indexOf('/relations/parents') > 0
        jsonPath = 'relation_resources.resources'

      if path.indexOf('/vocabulary') == 0 and path.indexOf('/contents') > 0
        jsonPath = 'resources.resources'

      if path.indexOf('/my/groups') == 0
        jsonPath = 'resources.resources'

      if path.indexOf('/vocabulary/keyword') == 0
        jsonPath = 'keyword.resources.resources'

      nextPage = (@currentPage + 1)
      nextUrl = setUrlParams(
        @url,
        {list: {page: nextPage}},
        {___sparse: JSON.stringify(f.set({}, jsonPath, {}))})

      # We compare the request id when sending started
      # with the request id when the answer arrives and
      # only process the answer when its still the same id.
      localRequestId = @requestId

      return xhr.get(
        {url: nextUrl, json: true },
        (err, res, body) => (

          if @requestId != localRequestId
            return

          if err || res.statusCode > 400
            return callback(err || body)

          @resources.add(f.get(body, jsonPath))
          @set({currentPage: nextPage})
          @fetchListData() if fetchListData
          callback(null)
      ))

    fetchAllResourceIds: (callback)->
      throw new Error('Callback missing!') if (!f.isFunction(callback))

      path = @url.pathname
      if path.indexOf('/relations/children') > 0 or path.indexOf('/relations/siblings') > 0 or path.indexOf('/relations/parents') > 0
        jsonPath = 'relation_resources.resources'

      if path.indexOf('/vocabulary') == 0 and path.indexOf('/contents') > 0
        jsonPath = 'resources.resources'

      if path.indexOf('/my/groups') == 0
        jsonPath = 'resources.resources'

      if path.indexOf('/vocabulary/keyword') == 0
        jsonPath = 'keyword.resources.resources'

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


    listMetadataJob: (resource) ->
      {
        state: 'waiting'
        groupId: resource.uuid
        id: 'list_meta_data'
        load: (callback) -> resource.loadListMetadata((err, res) -> callback(if err then 'failure' else 'success'))
        callback: (callback) ->
      }

    createPendingJobs: (resource) ->
      f.compact([
        @listMetadataJob(resource) unless resource.list_meta_data
      ])


    tryAddPendingJobs: (resource) ->
      jobs = @createPendingJobs(resource)
      f.each(
        jobs,
        (job) =>
          existing = f.find(@jobQueue, {groupId: job.groupId, id: job.id})
          if (not existing) && f.size(@jobQueue) < 10
            @jobQueue.push(job)
      )

    checkJobs: (callback) ->
      f.remove(@jobQueue, {state: 'done'})

      f.each(@pages, (page) =>
        f.each(page.resources, (resource) =>
          @tryAddPendingJobs(resource)
        )
      )

      waitingJobs = f.filter(
        @jobQueue,
        (job) ->
          job.state == 'waiting' || job.state == 'failure'
      )

      f.each(waitingJobs, (job) =>
        job.state = 'loading'
        job.load((result) =>
          if result == 'success'
            job.state = 'done'
          else
            job.state = 'failure'

          @checkJobs(callback)
        )
      )

      if callback
        callback()


    fetchListData: () ->

      @checkJobs()
