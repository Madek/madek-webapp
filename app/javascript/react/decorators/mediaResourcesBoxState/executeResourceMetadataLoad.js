import xhr from 'xhr'
import setUrlParams from '../../../lib/set-params-for-url.js'

import url from 'url'
import qs from 'qs'

const parseUrl = url.parse
const buildUrl = url.format
const parseQuery = qs.parse

function fetch(url, { success, error }) {
  xhr.get(
    {
      url: url,
      json: true
    },
    (err, res, json) => {
      if (err || res.statusCode > 400) {
        setTimeout(() => error(), 1000)
      } else {
        success(json)
      }
    }
  )
}

function executeResourceMetadataLoad(input) {
  const { trigger, initial, nextProps, data } = input

  const currentQuery = parseQuery(parseUrl(window.location.toString()).query)
  const getResourceUrl = () => {
    if (initial) {
      return nextProps.resource.list_meta_data_url
    } else {
      return data.resource.list_meta_data_url
    }
  }

  const parsedUrl = parseUrl(getResourceUrl(), true)
  delete parsedUrl.search

  const url = setUrlParams(buildUrl(parsedUrl), currentQuery)

  fetch(url, {
    success: json => {
      trigger(input, { action: 'load-meta-data-success', json: json })
    },
    error: () => trigger(input, { action: 'load-meta-data-failure' })
  })
}

module.exports = executeResourceMetadataLoad
