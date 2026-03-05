/**
 * Minimal jQuery stub for SSR (Server-Side Rendering)
 *
 * This stub provides just enough jQuery API to allow typeahead.jquery
 * to initialize without errors during SSR in ExecJS environment.
 *
 * Real jQuery is used in the browser - this stub is ONLY for SSR builds.
 *
 * WHY: typeahead.jquery requires jQuery, but jQuery requires window.document,
 * which doesn't exist in ExecJS. This stub provides the minimal API surface
 * that typeahead needs to initialize without throwing errors.
 */

// Main jQuery constructor function
const jQueryStub = function (selector) {
  // Return a minimal chainable object that implements jQuery-like API
  const instance = Object.create(jQueryStub.fn)
  instance.length = 0
  instance.selector = selector || ''
  return instance
}

// ============================================================================
// STATIC METHODS (jQuery.method)
// ============================================================================

/**
 * Type checking - delegates to native Array.isArray
 */
jQueryStub.isArray = Array.isArray

/**
 * Type checking - detects functions
 */
jQueryStub.isFunction = function (obj) {
  return typeof obj === 'function'
}

/**
 * Type checking - detects plain objects (not arrays, not null, not DOM nodes)
 */
jQueryStub.isPlainObject = function (obj) {
  if (!obj || typeof obj !== 'object') {
    return false
  }

  // Check if it's a plain object literal
  const proto = Object.getPrototypeOf(obj)
  return proto === null || proto === Object.prototype
}

/**
 * CRITICAL: Object extension/merging
 * Used by typeahead's _.mixin and _.clone functions
 *
 * Supports both shallow and deep merge:
 * - jQuery.extend(target, source1, source2, ...)  // shallow
 * - jQuery.extend(true, target, source1, ...)     // deep
 */
jQueryStub.extend = function () {
  let options, name, src, copy, copyIsArray, clone
  let target = arguments[0] || {}
  let i = 1
  let length = arguments.length
  let deep = false

  // Handle deep copy situation
  if (typeof target === 'boolean') {
    deep = target
    target = arguments[i] || {}
    i++
  }

  // Handle case when target is a string or something (possible in deep copy)
  if (typeof target !== 'object' && typeof target !== 'function') {
    target = {}
  }

  // Extend jQuery itself if only one argument is passed
  if (i === length) {
    target = this
    i--
  }

  for (; i < length; i++) {
    // Only deal with non-null/undefined values
    if ((options = arguments[i]) != null) {
      // Extend the base object
      for (name in options) {
        src = target[name]
        copy = options[name]

        // Prevent never-ending loop
        if (target === copy) {
          continue
        }

        // Recurse if we're merging plain objects or arrays
        if (
          deep &&
          copy &&
          (jQueryStub.isPlainObject(copy) || (copyIsArray = Array.isArray(copy)))
        ) {
          if (copyIsArray) {
            copyIsArray = false
            clone = src && Array.isArray(src) ? src : []
          } else {
            clone = src && jQueryStub.isPlainObject(src) ? src : {}
          }

          // Never move original objects, clone them
          target[name] = jQueryStub.extend(deep, clone, copy)
        } else if (copy !== undefined) {
          // Don't bring in undefined values
          target[name] = copy
        }
      }
    }
  }

  // Return the modified object
  return target
}

/**
 * Function binding - delegates to native Function.prototype.bind
 */
jQueryStub.proxy = function (fn, context) {
  if (typeof fn !== 'function') {
    return undefined
  }
  return fn.bind(context)
}

/**
 * Iteration over arrays and objects
 * Note: typeahead reverses the argument order, but we support both
 */
jQueryStub.each = function (obj, callback) {
  if (!obj) return obj

  const length = obj.length
  const isArrayLike = typeof length === 'number' && length >= 0

  if (isArrayLike) {
    // Array-like iteration
    for (let i = 0; i < length; i++) {
      if (callback.call(obj[i], i, obj[i]) === false) {
        break
      }
    }
  } else {
    // Object iteration
    for (let key in obj) {
      if (obj.hasOwnProperty(key)) {
        if (callback.call(obj[key], key, obj[key]) === false) {
          break
        }
      }
    }
  }

  return obj
}

/**
 * Array mapping
 */
jQueryStub.map = function (elems, callback) {
  if (!elems) return []

  const length = elems.length
  const isArrayLike = typeof length === 'number' && length >= 0
  const ret = []

  if (isArrayLike) {
    for (let i = 0; i < length; i++) {
      const value = callback(elems[i], i)
      if (value != null) {
        ret.push(value)
      }
    }
  } else {
    for (let key in elems) {
      if (elems.hasOwnProperty(key)) {
        const value = callback(elems[key], key)
        if (value != null) {
          ret.push(value)
        }
      }
    }
  }

  return ret
}

/**
 * Array filtering (jQuery calls it grep)
 */
jQueryStub.grep = function (elems, callback, invert) {
  const ret = []

  if (!elems) return ret

  for (let i = 0; i < elems.length; i++) {
    const callbackValue = !!callback(elems[i], i)
    if (callbackValue !== invert) {
      ret.push(elems[i])
    }
  }

  return ret
}

/**
 * Event object constructor
 * Used by typeahead's EventBus for triggering events
 */
jQueryStub.Event = function (type, props) {
  // Allow instantiation without 'new'
  if (!(this instanceof jQueryStub.Event)) {
    return new jQueryStub.Event(type, props)
  }

  this.type = type
  this.timeStamp = Date.now()
  this.isDefaultPrevented = false
  this.isPropagationStopped = false
  this.isImmediatePropagationStopped = false

  // Copy properties from props object
  if (props) {
    jQueryStub.extend(this, props)
  }
}

// Event prototype methods
jQueryStub.Event.prototype = {
  preventDefault: function () {
    this.isDefaultPrevented = true
  },
  stopPropagation: function () {
    this.isPropagationStopped = true
  },
  stopImmediatePropagation: function () {
    this.isImmediatePropagationStopped = true
    this.stopPropagation()
  }
}

// ============================================================================
// INSTANCE METHODS (jQuery.fn / jQuery.prototype)
// ============================================================================

jQueryStub.fn = jQueryStub.prototype = {
  // Version identifier (mark as stub for debugging)
  jquery: '3.7.1-stub-ssr',

  constructor: jQueryStub,

  length: 0,

  /**
   * Event triggering - no-op in SSR (no events can fire)
   */
  trigger: function () {
    return this
  },

  /**
   * DOM manipulation - empty element (no-op in SSR)
   */
  empty: function () {
    return this
  },

  /**
   * Get/set HTML content
   * In SSR, always return empty string for get, chainable for set
   */
  html: function (value) {
    if (arguments.length === 0) {
      return ''
    }
    return this
  },

  /**
   * Matcher checking - always false in SSR (no DOM to check)
   */
  is: function () {
    return false
  },

  /**
   * Add event listener - no-op in SSR
   */
  on: function () {
    return this
  },

  /**
   * Remove event listener - no-op in SSR
   */
  off: function () {
    return this
  },

  /**
   * DOM traversal - find elements (returns empty jQuery in SSR)
   */
  find: function () {
    return jQueryStub()
  },

  /**
   * DOM traversal - closest ancestor (returns empty jQuery in SSR)
   */
  closest: function () {
    return jQueryStub()
  },

  /**
   * Append content - no-op in SSR
   */
  append: function () {
    return this
  },

  /**
   * Add CSS class - no-op in SSR
   */
  addClass: function () {
    return this
  },

  /**
   * Remove CSS class - no-op in SSR
   */
  removeClass: function () {
    return this
  },

  /**
   * Get/set attribute
   */
  attr: function (name, value) {
    if (arguments.length === 1) {
      return undefined
    }
    return this
  },

  /**
   * Get/set text content
   */
  text: function (value) {
    if (arguments.length === 0) {
      return ''
    }
    return this
  },

  /**
   * Set focus - no-op in SSR
   */
  focus: function () {
    return this
  },

  /**
   * Remove focus - no-op in SSR
   */
  blur: function () {
    return this
  },

  /**
   * Get/set value
   */
  val: function (value) {
    if (arguments.length === 0) {
      return ''
    }
    return this
  },

  /**
   * Iterate over jQuery collection
   */
  each: function (callback) {
    // In SSR, collection is always empty, so this is a no-op
    return this
  }
}

// ============================================================================
// EXPORT
// ============================================================================

// Export default for ES modules (import jQuery from 'jquery')
export default jQueryStub

// Export named exports for CommonJS interop
// This is CRITICAL for Vite's getAugmentedNamespace to copy these to the wrapper
// Without these, typeahead.jquery won't have access to $2.extend, $2.isArray, etc.
export { jQueryStub as jQuery }

// Also export static methods and properties directly so they're available on the module object
// This ensures getAugmentedNamespace copies them to the augmented wrapper
export const extend = jQueryStub.extend
export const isArray = jQueryStub.isArray
export const isFunction = jQueryStub.isFunction
export const isPlainObject = jQueryStub.isPlainObject
export const proxy = jQueryStub.proxy
export const each = jQueryStub.each
export const map = jQueryStub.map
export const grep = jQueryStub.grep
export const Event = jQueryStub.Event

// CRITICAL: Export .fn so typeahead.jquery can access $.fn.typeahead
// typeahead tries to save the old $.fn.typeahead before installing itself
export const fn = jQueryStub.fn
