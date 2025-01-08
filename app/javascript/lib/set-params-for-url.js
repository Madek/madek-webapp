/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
let setUrlParams
const parseUrl = require('url').parse
const formatUrl = require('url').format
const qs = require('qs')
const { isString } = require('active-lodash')
const { isObject } = require('active-lodash')
const { merge } = require('active-lodash')
const { reduce } = require('active-lodash')
const { set } = require('active-lodash')

const parseQuery = qs.parse
const formatQuery = obj =>
  qs.stringify(obj, {
    skipNulls: true,
    arrayFormat: 'brackets' // NOTE: do it like rails
  })

// setUrlParams('/foo?foo=1&bar[baz]=2', {bar: {baz: 3}}, …)
// setUrlParams({path: '/foo', query: {foo: 1, bar: {baz: 2}}, {bar: {baz: 3}}, …)
// >>> '/foo?foo=1&bar[baz]=3'
module.exports = setUrlParams = function(currentUrl, ...params) {
  if (currentUrl == null) {
    currentUrl = ''
  }
  const url = urlFromStringOrObject(currentUrl)
  return formatUrl(
    merge(url, {
      path: null,
      pathname: url.pathname || url.path,
      search: formatQuery(merge(parseQuery(url.query), reduce(params, (a, b) => merge(a, b))))
    })
  )
}

var urlFromStringOrObject = function(url) {
  // NOTE: `path` must only be used if no `pathname` is given!
  switch (false) {
    case !isObject(url) || (!isString(url.path) && !isString(url.pathname)):
      return url // already parsed!
    case !isString(url):
      return (url => set(url, 'query', url.query))(parseUrl(url))
    default:
      throw new Error('Invalid URL!')
  }
}
