import { defaults, includes, merge } from 'lodash-es'
import BaseModel from './base-model.js'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import RailsResource from './rails-resource-mixin.js'

const customDataTypes = {
  // tri-state: can be true, false, or 'mixed'
  trilean: {
    compare(a, b) { return a === b },
    set(newVal) {
      if (includes([true, false, 'mixed'], newVal)) return { val: newVal, type: 'trilean' }
      return { val: newVal, type: `'${newVal}' (${typeof newVal})` }
    }
  }
}

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

  _runRequest(req, callback) {
    const { method = 'GET', url, body, json, headers: extra = {} } = req
    const isFormData = typeof FormData !== 'undefined' && body instanceof FormData
    const headers = {
      Accept: 'application/json',
      'X-CSRF-Token': getRailsCSRFToken(),
      ...extra
    }
    if (!isFormData) headers['Content-Type'] = 'application/json'
    fetch(url, {
      method,
      headers,
      body: body !== undefined ? body : json !== undefined ? JSON.stringify(json) : undefined
    })
      .then(async res => {
        let data
        try { data = await res.json() } catch (_) { data = null }
        callback(null, { statusCode: res.status }, data)
      })
      .catch(err => callback(err, null, null))
  }
})

export default AppResource
