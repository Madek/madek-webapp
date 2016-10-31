parseUrl = require('url').parse
formatUrl = require('url').format
qs = require('qs')
isString = require('active-lodash').isString
isObject = require('active-lodash').isObject
merge = require('active-lodash').merge
reduce = require('active-lodash').reduce
set = require('active-lodash').set

parseQuery = qs.parse
formatQuery = (obj)->
  qs.stringify(obj, {
    skipNulls: true,
    arrayFormat: 'brackets' # NOTE: do it like rails
  })

# setUrlParams('/foo?foo=1&bar[baz]=2', {bar: {baz: 3}}, …)
# setUrlParams({path: '/foo', query: {foo: 1, bar: {baz: 2}}, {bar: {baz: 3}}, …)
# >>> '/foo?foo=1&bar[baz]=3'
module.exports = setUrlParams = (currentUrl = '', params...)->
  url = urlFromStringOrObject(currentUrl)
  formatUrl({
    pathname: url.pathname,
    search: formatQuery(
      merge(parseQuery(url.query), reduce(params, (a, b)-> merge(a, b))))})

urlFromStringOrObject = (url)->
  switch
    when (isObject(url) and (isString(url.path) or isString(url.pathname)))
      url # already parsed!
    when isString(url)
      do (url = parseUrl(url))-> set(url, 'query', url.query)
    else
      throw new Error 'Invalid URL!'
