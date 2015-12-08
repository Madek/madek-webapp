# NOTE: keep in sync with `app/controllers/concerns/resource_list_params.rb`!

f = require('active-lodash')
qs = require('qs')

module.exports = resourceListParams = (location)->
  query = qs.parse(location.search.slice(1))
  base = 'list'
  allowed = ['layout', 'filter', 'search', 'show_filter', 'page', 'per_page']
  coerced_types = { bools: ['show_filter'], jsons: ['filter', 'dyn_filter'] }
  f.chain(query)
    .get(base).pick(allowed)
    .map(f.curry(coerceTypes)(coerced_types)).object()
    .merge(
      for_url:
        path: location.pathname
        query: query)
    .value()

# private

coerceTypes = (types, val, key)->
  switch
    when f.include(types.bools, key) then [key, val is 'true']
    when f.include(types.jsons, key) then [key, parseJsonParam(key, val)]
    else
      [key, val]

parseJsonParam = (key, val)->
  try
    JSON.parse(val)
  catch e
    throw new Error "'#{key}' must be valid JSON!\n#{e}"
