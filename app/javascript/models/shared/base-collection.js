// BaseCollection — replaces ampersand-rest-collection.
//
// Wraps a models[] array with event emission, Backbone-style add/remove/set/reset,
// a static extend() factory, and a sync() stub for MetaData.save compat.

import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import BaseModel from './base-model.js'

const SKIP_METHOD_KEYS = new Set([
  'type', 'model', 'isModel', 'parse', 'initialize',
  'mainIndex', 'indexes', 'ajaxConfig'
])

class BaseCollection {
  constructor(data = []) {
    this._listeners = {}
    this._listenedTo = []
    this.models = []
    this.isCollection = true

    const config = this.constructor._config || {}
    const raw = Array.isArray(data) ? data : []
    const parsed = config.parse ? config.parse.call(this, data) : raw
    if (config.initialize) config.initialize.call(this, data)
    if (parsed && parsed.length) this._setModels(parsed)
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  _createModel(attrs) {
    if (!attrs) return attrs
    const config  = this.constructor._config || {}
    const modelFn = config.model
    if (!modelFn) return attrs
    // Distinguish class (extends BaseModel) from factory function
    if (modelFn.prototype instanceof BaseModel) return new modelFn(attrs)
    return modelFn.call(this, attrs, {})
  }

  _setModels(arr) {
    this.models = arr.map(d => {
      if (d instanceof BaseModel) return d
      return this._createModel(d)
    })
  }

  // ── Event emitter (same API as BaseModel) ──────────────────────────────────

  on(event, fn) {
    ;(this._listeners[event] = this._listeners[event] || []).push(fn)
    return this
  }

  off(event, fn) {
    if (!event) { this._listeners = {}; return this }
    if (!fn)    { this._listeners[event] = []; return this }
    this._listeners[event] = (this._listeners[event] || []).filter(f => f !== fn)
    return this
  }

  trigger(event, ...args) {
    const list = this._listeners[event]
    if (list) list.slice().forEach(fn => fn(...args))
    return this
  }

  listenTo(other, event, fn) {
    other.on(event, fn)
    this._listenedTo.push({ other, event, fn })
    return this
  }

  // ── Array-like interface ───────────────────────────────────────────────────

  get length() { return this.models.length }

  map(fn)     { return this.models.map(fn) }
  filter(fn)  { return this.models.filter(fn) }
  find(fn)    { return this.models.find(fn) }
  some(fn)    { return this.models.some(fn) }
  every(fn)   { return this.models.every(fn) }
  forEach(fn) { return this.models.forEach(fn) }

  get(id) {
    return this.models.find(m => m.url === id || m.uuid === id)
  }

  has(id) { return !!this.get(id) }

  // ── Mutation ───────────────────────────────────────────────────────────────

  add(attrsOrArray) {
    const items = Array.isArray(attrsOrArray) ? attrsOrArray : [attrsOrArray]
    items.forEach(attrs => {
      const model = this._createModel(attrs)
      this.models.push(model)
      this.trigger('add', model)
    })
    this.trigger('change')
    return this
  }

  remove(model) {
    const idx = this.models.indexOf(model)
    if (idx >= 0) {
      this.models.splice(idx, 1)
      this.trigger('remove', model)
      this.trigger('change')
    }
    return this
  }

  // set([]) clears; set([…]) replaces all models
  set(data) {
    const arr = Array.isArray(data) ? data : (data ? [data] : [])
    this._setModels(arr)
    this.trigger('reset')
    this.trigger('change')
    return this
  }

  reset(data) { return this.set(data) }

  // ── Serialization ──────────────────────────────────────────────────────────

  serialize() {
    return this.models.map(m => m && m.serialize ? m.serialize() : m)
  }

  // ── sync — compatibility shim for MetaData.save() ─────────────────────────
  // Called as: AppCollection.prototype.sync.call(this, 'update', this, opts)
  // where opts.url and opts.json are set.

  sync(method, model, opts = {}) {
    const methodMap = { create: 'POST', update: 'PUT', patch: 'PATCH', delete: 'DELETE', read: 'GET' }
    const httpMethod = opts.method || methodMap[method] || 'GET'
    return fetch(opts.url, {
      method: httpMethod,
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        'X-CSRF-Token': getRailsCSRFToken()
      },
      body: opts.json ? JSON.stringify(opts.json) : undefined
    }).then(async res => {
      let data
      try { data = await res.json() } catch (_) { data = null }
      const resp = { statusCode: res.status, body: data }
      if (res.ok) {
        if (opts.success) opts.success(model, data, resp)
      } else {
        if (opts.error) opts.error(model, resp)
      }
      return res
    }).catch(err => {
      if (opts.error) opts.error(model, err)
      throw err
    })
  }

  // ── Class factory ──────────────────────────────────────────────────────────

  static extend(...args) {
    const ownConfig = args[args.length - 1] || {}
    const Parent    = this

    const parentConfig = Parent._config || {}
    const merged = {
      ...parentConfig,
      ...ownConfig,
      // keep parse/initialize from own config if provided
    }

    class Extended extends Parent {}
    Extended._config = merged

    // Apply instance methods
    Object.entries(ownConfig).forEach(([key, val]) => {
      if (!SKIP_METHOD_KEYS.has(key)) Extended.prototype[key] = val
    })

    Extended.extend = BaseCollection.extend.bind(Extended)
    Extended.prototype.sync = Parent.prototype.sync

    return Extended
  }
}

export default BaseCollection
