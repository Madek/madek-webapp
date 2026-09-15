import { defaults, merge } from 'lodash-es'
import xhr from 'xhr'
import BaseModel from './base-model.js'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import RailsResource from './rails-resource-mixin.js'

// Base class for RESTful application resources
const AppResource = BaseModel.extend(RailsResource, {
  type: 'AppResource',
  idAttribute: 'url',
  props: {
    url: 'string',
    uuid: 'string'
  },

  save(config) {
    return BaseModel.prototype.save.call(this, defaults({}, config, { wait: true }))
  },

  merge(prop, data) {
    return this.set(prop, merge(this[prop], data))
  },

  dump() {
    return this.serialize()
  },

  // ajax helper (XHR so upload beforeSend/progress works)
  _runRequest(req, callback) {
    const headers = {
      Accept: 'application/json',
      'X-CSRF-Token': getRailsCSRFToken(),
      ...(req.headers || {})
    }
    let body = req.body
    if (body === undefined && req.json !== undefined) {
      body = JSON.stringify(req.json)
      headers['Content-Type'] = 'application/json'
    }

    return xhr(
      {
        method: req.method,
        url: req.url,
        body,
        beforeSend: req.beforeSend,
        headers
      },
      function (err, res, body) {
        const data =
          (() => {
            try {
              return JSON.parse(body)

              // eslint-disable-next-line no-unused-vars
            } catch (e) {
              // this is OK, just fallback to unparsed body
            }
          })() || body
        return callback(err, res, data)
      }
    )
  }
})

export default AppResource
