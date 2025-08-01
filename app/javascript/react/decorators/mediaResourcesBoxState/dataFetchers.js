import __ from 'lodash'
import xhr from 'xhr'
import setUrlParams from '../../../lib/set-params-for-url.js'
import url from 'url'
import qs from 'qs'

const parseUrl = url.parse
const buildUrl = url.format
const parseQuery = qs.parse

function fetchPage({ currentUrl, sparsePath, page, onFetched }) {
  const url = setUrlParams(
    currentUrl,
    { list: { page } },
    {
      ___sparse: JSON.stringify(__.set({}, sparsePath, {}))
    }
  )

  return xhr.get({ url, json: true }, (err, res, body) => {
    if (res.statusCode === 200) {
      const resources = __.get(body, sparsePath)
      onFetched({ success: true, resources })
    } else {
      onFetched({ success: false })
    }
  })
}

function fetchListMetadata({ resourceUrl, onFetched }) {
  const currentQuery = parseQuery(parseUrl(window.location.toString()).query)
  const parsedUrl = parseUrl(resourceUrl, true)
  delete parsedUrl.search

  const url = setUrlParams(buildUrl(parsedUrl), currentQuery)

  xhr.get(
    {
      url: url,
      json: true
    },
    (err, res, json) => {
      if (err || res.statusCode > 400) {
        setTimeout(() => onFetched({ success: false }), 1000)
      } else {
        onFetched({ success: true, json })
      }
    }
  )
}

module.exports = { fetchPage, fetchListMetadata }
