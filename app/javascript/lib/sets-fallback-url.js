/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const f = require('active-lodash')
const parseUrl = require('url').parse
const stringifyUrl = require('url').format
const parseQuery = require('qs').parse

const setUrlParams = require('./set-params-for-url.js')

module.exports = function(url, usePathUrlReplacement) {
  // The fallback url is used for search results if there are no
  // entries found but potentially sets.
  // If we are on a box which toggles between /entries and /sets,
  // we simply replace /entries with /sets.
  // Otherwise we use type='collections' as url parameter.
  // The whole thing however only works, when we have no filters
  // other than search, because the filters for sets are not yet
  // implemented. In this case we simply return nothing.

  const currentUrl = parseUrl(url)
  const currentParams = parseQuery(currentUrl.query)

  const newParams = f.cloneDeep(currentParams)
  if (newParams.list) {
    if (newParams.list.accordion) {
      newParams.list.accordion = {}
    }

    if (newParams.list.filter) {
      const parsed = (() => {
        try {
          return JSON.parse(newParams.list.filter)
          // eslint-disable-next-line no-empty
        } catch (error) {}
      })()
      if (parsed) {
        newParams.list.filter = JSON.stringify({ search: parsed.search })
      } else {
        newParams.list.filter = JSON.stringify({})
      }
    }

    newParams.list.page = 1
  }

  if (usePathUrlReplacement) {
    const currentPath = 'entries'
    const newPath = 'sets'
    return setUrlParams(currentUrl.pathname.replace(RegExp(`/${currentPath}$`), `/${newPath}`), {
      list: newParams.list
    })
  } else {
    return setUrlParams(currentUrl, { list: newParams.list }, { type: 'collections' })
  }
}
