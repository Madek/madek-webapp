f = require('active-lodash')
parseUrl = require('url').parse
stringifyUrl = require('url').format
parseQuery = require('qs').parse

setUrlParams = require('./set-params-for-url.coffee')


module.exports = (url, usePathUrlReplacement) ->

  # The fallback url is used for search results if there are no
  # entries found but potentially sets.
  # If we are on a box which toggles between /entries and /sets,
  # we simply replace /entries with /sets.
  # Otherwise we use type='collections' as url parameter.
  # The whole thing however only works, when we have no filters
  # other than search, because the filters for sets are not yet
  # implemented. In this case we simply return nothing.

  currentUrl = parseUrl(url)
  currentParams = parseQuery(currentUrl.query)

  newParams = f.cloneDeep(currentParams)
  if newParams.list

    if newParams.list.accordion
      newParams.list.accordion = {}

    if newParams.list.filter
      parsed = (try JSON.parse(newParams.list.filter))
      if parsed
        newParams.list.filter = JSON.stringify({search: parsed.search})
      else
        newParams.list.filter = JSON.stringify({})

    newParams.list.page = 1


  if usePathUrlReplacement
    currentPath = 'entries'
    newPath = 'sets'
    setUrlParams(
      currentUrl.pathname.replace(RegExp("\/#{currentPath}$"), "\/#{newPath}"),
      {list: newParams.list}
    )
  else
    setUrlParams(
      currentUrl,
      {list: newParams.list},
      {type: 'collections'}
    )
