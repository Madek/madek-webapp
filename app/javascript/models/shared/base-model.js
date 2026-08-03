// BaseModel — replaces ampersand-model and ampersand-state.
//
// Supports: props, session, children, collections, derived (as getters),
// extraProperties:'allow', initialize(), on/off/trigger/listenTo,
// set/get/merge, serialize, _runRequest, save/fetch/destroy, and
// the static extend() class factory that mirrors Ampersand's API.

import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

// Normalize prop declaration forms to a default value.
// Accepted: 'string' | ['string'] | ['string', required, default] | { type, default, … }
function propDefault(def) {
  if (Array.isArray(def)) return def[2]
  if (def && typeof def === 'object') return def.default
  return undefined
}

// Walk the prototype chain to detect derived (getter-only) properties.
function isDerivedKey(instance, key) {
  let proto = Object.getPrototypeOf(instance)
  while (proto && proto !== Object.prototype) {
    const desc = Object.getOwnPropertyDescriptor(proto, key)
    if (desc) return !!desc.get
    proto = Object.getPrototypeOf(proto)
  }
  return false
}

// Merge parent config, mixin configs, and own config into one flat object.
const CONFIG_KEYS = new Set([
  'props',
  'session',
  'children',
  'collections',
  'derived',
  'initialize'
])
const SKIP_METHOD_KEYS = new Set([
  ...CONFIG_KEYS,
  'type',
  'urlRoot',
  'idAttribute',
  'extraProperties',
  'dataTypes',
  'typeAttribute',
  'mainIndex',
  'indexes',
  'ajaxConfig'
])

function mergeConfigs(parentConfig = {}, mixins, ownConfig) {
  const merged = {
    props: { ...(parentConfig.props || {}) },
    session: { ...(parentConfig.session || {}) },
    children: { ...(parentConfig.children || {}) },
    collections: { ...(parentConfig.collections || {}) },
    derived: { ...(parentConfig.derived || {}) },
    extraProperties: parentConfig.extraProperties,
    initialize: parentConfig.initialize,
    type: ownConfig.type !== undefined ? ownConfig.type : parentConfig.type
  }

  mixins.forEach(mixin => {
    if (mixin.props) Object.assign(merged.props, mixin.props)
    if (mixin.session) Object.assign(merged.session, mixin.session)
    if (mixin.children) Object.assign(merged.children, mixin.children)
    if (mixin.collections) Object.assign(merged.collections, mixin.collections)
    if (mixin.derived) Object.assign(merged.derived, mixin.derived)
    if (mixin.initialize) merged.initialize = mixin.initialize
    if (mixin.extraProperties) merged.extraProperties = mixin.extraProperties
  })

  if (ownConfig.props) Object.assign(merged.props, ownConfig.props)
  if (ownConfig.session) Object.assign(merged.session, ownConfig.session)
  if (ownConfig.children) Object.assign(merged.children, ownConfig.children)
  if (ownConfig.collections) Object.assign(merged.collections, ownConfig.collections)
  if (ownConfig.derived) Object.assign(merged.derived, ownConfig.derived)
  if (ownConfig.initialize) merged.initialize = ownConfig.initialize
  if (ownConfig.extraProperties) merged.extraProperties = ownConfig.extraProperties

  return merged
}

class BaseModel {
  constructor(data = {}) {
    this._listeners = {}
    this._listenedTo = []
    this._initFromConfig(data)
  }

  _initFromConfig(data) {
    const config = this.constructor._config || {}
    const allProps = { ...(config.props || {}), ...(config.session || {}) }

    // Set type from config (ampersand-model sets this on every instance)
    if (config.type !== undefined) this.type = config.type

    // Declared props/session with defaults
    Object.entries(allProps).forEach(([key, def]) => {
      this[key] = key in data ? data[key] : propDefault(def)
    })

    // Children: instantiate nested models
    Object.entries(config.children || {}).forEach(([key, ChildClass]) => {
      this[key] = data[key] != null ? new ChildClass(data[key]) : null
    })

    // Collections: instantiate nested collections
    Object.entries(config.collections || {}).forEach(([key, CollClass]) => {
      const coll = new CollClass(data[key] || [])
      coll.parent = this
      this[key] = coll
    })

    // extraProperties:'allow' — store any undeclared key from data
    if (config.extraProperties === 'allow') {
      const handled = new Set([
        ...Object.keys(allProps),
        ...Object.keys(config.children || {}),
        ...Object.keys(config.collections || {}),
        ...Object.keys(config.derived || {})
      ])
      Object.entries(data).forEach(([key, val]) => {
        if (!handled.has(key)) this[key] = val
      })
    }

    if (config.initialize) config.initialize.call(this, data)
  }

  // ── Event emitter ──────────────────────────────────────────────────────────

  on(event, fn) {
    ;(this._listeners[event] = this._listeners[event] || []).push(fn)
    return this
  }

  off(event, fn) {
    if (!event) {
      this._listeners = {}
      return this
    }
    if (!fn) {
      this._listeners[event] = []
      return this
    }
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

  stopListening(other) {
    this._listenedTo = this._listenedTo.filter(({ other: o, event, fn }) => {
      if (!other || o === other) {
        o.off(event, fn)
        return false
      }
      return true
    })
  }

  // ── Property access ────────────────────────────────────────────────────────

  set(keyOrObj, val) {
    if (keyOrObj && typeof keyOrObj === 'object') {
      Object.entries(keyOrObj).forEach(([k, v]) => this.set(k, v))
      return this
    }
    if (isDerivedKey(this, keyOrObj)) return this
    this[keyOrObj] = val
    this.trigger('change')
    return this
  }

  get(key) {
    return this[key]
  }

  merge(prop, data) {
    return this.set(prop, Object.assign({}, this[prop], data))
  }

  unset(key) {
    this[key] = undefined
    this.trigger('change')
    return this
  }

  // Re-hydrate from server data, preserving nested model/collection types.
  _applyData(data) {
    const config = this.constructor._config || {}
    const allProps = { ...(config.props || {}), ...(config.session || {}) }
    Object.entries(data).forEach(([key, val]) => {
      if (key in allProps) {
        this[key] = val
      } else if (config.children && key in config.children) {
        this[key] = val != null ? new config.children[key](val) : null
      } else if (config.collections && key in config.collections) {
        const coll = new config.collections[key](val || [])
        coll.parent = this
        this[key] = coll
      } else if (config.extraProperties === 'allow' && !isDerivedKey(this, key)) {
        this[key] = val
      }
    })
  }

  // ── Serialization ──────────────────────────────────────────────────────────

  serialize() {
    const config = this.constructor._config || {}
    const result = {}

    Object.keys(config.props || {}).forEach(key => {
      result[key] = this[key]
    })

    Object.keys(config.children || {}).forEach(key => {
      const child = this[key]
      result[key] = child && child.serialize ? child.serialize() : child
    })

    Object.keys(config.collections || {}).forEach(key => {
      const coll = this[key]
      result[key] = coll && coll.serialize ? coll.serialize() : coll || []
    })

    return result
  }

  dump() {
    return this.serialize()
  }

  // ── HTTP ───────────────────────────────────────────────────────────────────

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
        try {
          data = await res.json()
        } catch {
          data = null
        }
        callback(null, { statusCode: res.status }, data)
      })
      .catch(err => callback(err, null, null))
  }

  save(config = {}) {
    this._runRequest({ method: 'PUT', url: this.url, json: this.serialize() }, (err, res, data) => {
      if (err || res.statusCode >= 400) {
        if (config.error) config.error(this, err || data)
      } else {
        if (data && typeof data === 'object') this._applyData(data)
        if (config.success) config.success(this)
      }
    })
  }

  fetch(config = {}) {
    this._runRequest({ method: 'GET', url: this.url }, (err, res, data) => {
      if (err || res.statusCode >= 400) {
        if (config.error) config.error(this, err || data)
      } else {
        if (data && typeof data === 'object') this._applyData(data)
        if (config.success) config.success(this)
      }
    })
  }

  destroy(config = {}) {
    this._runRequest({ method: 'DELETE', url: this.url }, (err, res, data) => {
      if (err || res.statusCode >= 400) {
        if (config.error) config.error(this, err || data)
      } else {
        if (config.success) config.success(this)
      }
    })
  }

  // ── Class factory ──────────────────────────────────────────────────────────

  static extend(...args) {
    const ownConfig = args[args.length - 1] || {}
    const mixins = args.slice(0, -1)
    const Parent = this

    const merged = mergeConfigs(Parent._config || {}, mixins, ownConfig)

    class Extended extends Parent {}

    Extended._config = merged

    // Apply instance methods from mixins (functions only, no config-key props)
    mixins.forEach(mixin => {
      Object.entries(mixin).forEach(([key, val]) => {
        if (!SKIP_METHOD_KEYS.has(key) && typeof val === 'function') {
          Extended.prototype[key] = val
        }
      })
    })

    // Apply own config instance methods
    Object.entries(ownConfig).forEach(([key, val]) => {
      if (!SKIP_METHOD_KEYS.has(key)) Extended.prototype[key] = val
    })

    // Define derived properties as getters on the prototype
    Object.entries(merged.derived || {}).forEach(([key, { fn }]) => {
      Object.defineProperty(Extended.prototype, key, {
        get: fn,
        enumerable: true,
        configurable: true
      })
    })

    Extended.extend = BaseModel.extend.bind(Extended)

    return Extended
  }
}

export default BaseModel
