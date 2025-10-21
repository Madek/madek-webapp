/**
 * Utility helpers to replace lodash/active-lodash functionality with native JavaScript
 */

/**
 * Check if value is present (not null, undefined, or empty)
 * Replacement for active-lodash `present`
 */
export const present = (val) => {
  return (
    typeof val !== 'undefined' &&
    val !== null &&
    (typeof val !== 'object' || 
      (Array.isArray(val) ? val.length > 0 : Object.keys(val).length > 0) ||
      typeof val === 'number' ||
      typeof val === 'boolean' ||
      typeof val === 'function')
  )
}

/**
 * Return value if present, undefined otherwise
 * Replacement for active-lodash `presence`
 */
export const presence = (val) => {
  return present(val) ? val : undefined
}

/**
 * Convert string to kebab-case
 * Replacement for lodash `kebabCase`
 */
export const kebabCase = (str) => {
  return str
    .replace(/([a-z])([A-Z])/g, '$1-$2')
    .replace(/[\s_]+/g, '-')
    .toLowerCase()
}

/**
 * Convert string to snake_case
 * Replacement for lodash `snakeCase`
 */
export const snakeCase = (str) => {
  return str
    .replace(/([a-z])([A-Z])/g, '$1_$2')
    .replace(/[\s-]+/g, '_')
    .toLowerCase()
}

/**
 * Get nested property value with default
 * Replacement for lodash `get`
 */
export const get = (obj, path, defaultValue) => {
  if (!obj || typeof path !== 'string') return defaultValue
  
  const keys = path.split('.')
  let result = obj
  
  for (const key of keys) {
    if (result == null || result === undefined) return defaultValue
    result = result[key]
    if (result === undefined) return defaultValue
  }
  
  return result !== undefined ? result : defaultValue
}

/**
 * Omit properties from object
 * Replacement for lodash `omit`
 */
export const omit = (obj, keys) => {
  const keysToOmit = Array.isArray(keys) ? keys : [keys]
  return Object.keys(obj).reduce((result, key) => {
    if (!keysToOmit.includes(key)) {
      result[key] = obj[key]
    }
    return result
  }, {})
}

/**
 * Check if value is empty
 * Replacement for lodash `isEmpty`
 */
export const isEmpty = (value) => {
  if (value == null) return true
  if (Array.isArray(value) || typeof value === 'string') return value.length === 0
  if (typeof value === 'object') return Object.keys(value).length === 0
  return false
}

/**
 * Deep clone an object
 * Replacement for lodash `cloneDeep`
 */
export const cloneDeep = (obj) => {
  // For modern browsers, use structuredClone if available
  if (typeof structuredClone === 'function') {
    return structuredClone(obj)
  }
  // Fallback to JSON method (has limitations with functions, dates, etc.)
  return JSON.parse(JSON.stringify(obj))
}
