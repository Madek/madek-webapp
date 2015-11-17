parseUrl = require('url').parse
formatUrl = require('url').format
parseQuery = require('qs').parse
formatQuery = require('qs').stringify
isString = require('active-lodash').isString
isObject = require('active-lodash').isObject
merge = require('active-lodash').merge
reduce = require('active-lodash').reduce
set = require('active-lodash').set

# setUrlParams('/foo?foo=1&bar[baz]=2', {bar: {baz: 3}}, …)
# setUrlParams({path: '/foo', query: {foo: 1, bar: {baz: 2}}, {bar: {baz: 3}}, …)
# >>> '/foo?foo=1&bar[baz]=3'
module.exports = setUrlParams = (currentUrl = '', params...)->
  url = urlFromStringOrObject(currentUrl)
  formatUrl
    pathname: url.pathname
    search: formatQuery(merge(url.query, reduce(params, (a, b)-> merge(a, b))))

urlFromStringOrObject = (url)->
  switch
    when (isObject(url) and (isString(url.path) or isString(url.pathname)))
      {pathname: url.path or url.pathname, query: url.query}
    when isString(url)
      do (url = parseUrl(url))-> set(url, 'query', parseQuery(url.query) )
    else
      throw new Error 'Invalid URL!'
