import { curry, get, includes, map, merge, pick } from 'lodash-es'
import qs from 'qs'

export default function (location) {
  const query = qs.parse(location.search.slice(1))
  const base = 'list'
  const allowed = ['layout', 'filter', 'show_filter', 'accordion', 'page', 'per_page', 'order']
  const coerced_types = { bools: ['show_filter'], jsons: ['filter', 'accordion'] }
  const coerced = Object.fromEntries(
    map(pick(get(query, base), allowed), curry(coerceTypes)(coerced_types))
  )
  return merge(coerced, {
    for_url: {
      pathname: location.pathname,
      query
    }
  })
}

// private

var coerceTypes = function (types, val, key) {
  switch (true) {
    case includes(types.bools, key):
      return [key, val === 'true']
    case includes(types.jsons, key):
      return [key, parseJsonParam(key, val)]
    case key === 'order':
      return [key, val === 'last_change' ? 'last_change DESC' : val]
    default:
      return [key, val]
  }
}

var parseJsonParam = function (key, val) {
  try {
    return JSON.parse(val)
  } catch (e) {
    throw new Error(`'${key}' must be valid JSON!\n${e}`)
  }
}
