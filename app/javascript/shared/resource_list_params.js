/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// NOTE: keep in sync with `app/controllers/concerns/resource_list_params.rb`!

import f from 'active-lodash'
import qs from 'qs'

module.exports = function(location) {
  const query = qs.parse(location.search.slice(1))
  const base = 'list'
  const allowed = ['layout', 'filter', 'show_filter', 'accordion', 'page', 'per_page', 'order']
  const coerced_types = { bools: ['show_filter'], jsons: ['filter', 'accordion'] }
  return f
    .chain(query)
    .get(base)
    .pick(allowed)
    .map(f.curry(coerceTypes)(coerced_types))
    .object()
    .merge({
      for_url: {
        pathname: location.pathname,
        query
      }
    })
    .value()
}

// private

var coerceTypes = function(types, val, key) {
  switch (false) {
    case !f.include(types.bools, key):
      return [key, val === 'true']
    case !f.include(types.jsons, key):
      return [key, parseJsonParam(key, val)]
    default:
      return [key, val]
  }
}

var parseJsonParam = function(key, val) {
  try {
    return JSON.parse(val)
  } catch (e) {
    throw new Error(`'${key}' must be valid JSON!\n${e}`)
  }
}
