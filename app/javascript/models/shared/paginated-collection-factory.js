/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// This is a (simple) factory, used by ModelCollections that can paginate.

const f = require('active-lodash')
const State = require('ampersand-state')
const Collection = require('ampersand-rest-collection')
const AppCollection = require('./app-collection.js')

const xhr = require('xhr')
const setUrlParams = require('../../lib/set-params-for-url.js')
const getOrThrow = function(obj, key) {
  const val = f.get(obj, key)
  if (!f.present(val)) {
    throw new Error('Missing config! ' + key)
  }
  return val
}

module.exports = function(collectionClass, { jsonPath }) {
  return State.extend({
    collections: {
      resources: collectionClass
    },

    props: {
      url: ['object'],
      perPage: ['number'],
      firstPage: ['number'],
      currentPage: ['number'],
      totalCount: ['number'],
      jobQueue: ['array'],
      requestId: ['number'],
      jsonPath: ['string']
    },

    derived: {
      // make it behave more like a normal collection (for controllers)
      models: {
        deps: ['resources'],
        fn() {
          return this.resources.models
        }
      },
      length: {
        deps: ['resources'],
        fn() {
          return this.resources.length
        }
      },

      totalPages: {
        deps: ['totalCount', 'perPage'],
        fn() {
          return Math.ceil(this.totalCount / this.perPage)
        }
      },

      hasNext: {
        deps: ['currentPage', 'totalPages'],
        fn() {
          return this.totalPages > this.currentPage
        }
      },

      // return resources by pages (for rendering)
      // [{ resources: [{…}, …], pagination: { page: 1, … } }, …]
      pages: {
        deps: ['currentPage', 'resources', 'totalPages', 'totalCount', 'perPage'],
        fn() {
          const paginationBase = { totalPages: this.totalPages, totalCount: this.totalCount }

          return f(this.resources.models)
            .chunk(this.perPage)
            .map((resources, n) => ({
              url: setUrlParams(this.url, { list: { page: this.firstPage + n } }),
              resources,
              pagination: f.extend(paginationBase, { page: this.firstPage + n })
            }))
            .value()
        }
      }
    },

    initialize(data) {
      this.set({
        url: getOrThrow(data, 'config.for_url'),
        perPage: getOrThrow(data, 'config.per_page'),
        firstPage: getOrThrow(data, 'config.page'),
        currentPage: getOrThrow(data, 'config.page'),
        totalCount: getOrThrow(data, 'pagination.total_count'),
        totalPages: getOrThrow(data, 'pagination.total_pages'),
        jsonPath: f.get(data, 'json_path'),
        requestId: Math.random(),
        jobQueue: []
      })
      // listen to child collections
      if (this.resources && f.isFunction(this.resources.on)) {
        return this.resources != null
          ? this.resources.on('change add remove reset', e => this.trigger('change'))
          : undefined
      }
    },

    // instance methods:

    clearPages(url) {
      this.set({
        currentPage: 0,
        url,
        requestId: Math.random()
      })
      return this.resources.set([])
    },

    // fetches the next page of `resources`
    fetchNext(fetchListData, callback) {
      if (!f.isFunction(callback)) {
        throw new Error('Callback missing!')
      }
      if (!this.currentPage && this.currentPage !== 0) {
        return callback(null)
      }

      const nextPage = this.currentPage + 1
      const nextUrl = setUrlParams(
        this.url,
        { list: { page: nextPage } },
        { ___sparse: JSON.stringify(f.set({}, this.getJsonPath(), {})) }
      )

      // We compare the request id when sending started
      // with the request id when the answer arrives and
      // only process the answer when its still the same id.
      const localRequestId = this.requestId

      return xhr.get({ url: nextUrl, json: true }, (err, res, body) => {
        if (this.requestId !== localRequestId) {
          return
        } else if (err || res.statusCode > 400) {
          return callback(err || body)
        } else {
          this.resources.add(f.get(body, this.getJsonPath()))
          this.set({ currentPage: nextPage })
          if (fetchListData) {
            this.fetchListData()
          }
          return callback(null)
        }
      })
    },

    getJsonPath() {
      if (this.jsonPath) {
        return this.jsonPath
      }

      const path = this.url.pathname
      if (
        path.indexOf('/relations/children') > 0 ||
        path.indexOf('/relations/siblings') > 0 ||
        path.indexOf('/relations/parents') > 0
      ) {
        return 'relation_resources.resources'
      }

      if (path.indexOf('/vocabulary') === 0 && path.indexOf('/content') > 0) {
        return 'resources.resources'
      }

      if (path.indexOf('/my/groups') === 0) {
        return 'resources.resources'
      }

      if (path.indexOf('/vocabulary/keyword') === 0) {
        return 'keyword.resources.resources'
      }

      if (path.indexOf('/people') === 0) {
        return 'resources.resources'
      }

      return jsonPath
    },

    fetchAllResourceIds(callback) {
      if (!f.isFunction(callback)) {
        throw new Error('Callback missing!')
      }

      const nextUrl = setUrlParams(
        this.url,
        { list: { page: 1, per_page: this.totalCount } },
        { ___sparse: JSON.stringify(f.set({}, this.getJsonPath(), [{ uuid: {}, type: {} }])) }
      )

      return xhr.get({ url: nextUrl, json: true }, (err, res, body) => {
        if (err || res.statusCode > 400) {
          return callback({ result: 'error' })
        } else {
          return callback({
            result: 'success',
            data: f.get(body, this.getJsonPath())
          })
        }
      })
    },

    listMetadataJob(resource) {
      return {
        state: 'waiting',
        groupId: resource.uuid,
        id: 'list_meta_data',
        load(callback) {
          return resource.loadListMetadata((err, res) => callback(err ? 'failure' : 'success'))
        },
        callback(callback) {}
      }
    },

    createPendingJobs(resource) {
      return f.compact([!resource.list_meta_data ? this.listMetadataJob(resource) : undefined])
    },

    tryAddPendingJobs(resource) {
      const jobs = this.createPendingJobs(resource)
      return f.each(jobs, job => {
        const existing = f.find(this.jobQueue, { groupId: job.groupId, id: job.id })
        if (!existing && f.size(this.jobQueue) < 10) {
          return this.jobQueue.push(job)
        }
      })
    },

    checkJobs(callback) {
      f.remove(this.jobQueue, { state: 'done' })

      f.each(this.pages, page => {
        return f.each(page.resources, resource => {
          return this.tryAddPendingJobs(resource)
        })
      })

      const waitingJobs = f.filter(
        this.jobQueue,
        job => job.state === 'waiting' || job.state === 'failure'
      )

      f.each(waitingJobs, job => {
        job.state = 'loading'
        return job.load(result => {
          if (result === 'success') {
            job.state = 'done'
          } else {
            job.state = 'failure'
          }

          return this.checkJobs(callback)
        })
      })

      if (callback) {
        return callback()
      }
    },

    fetchListData() {
      return this.checkJobs()
    }
  })
}
