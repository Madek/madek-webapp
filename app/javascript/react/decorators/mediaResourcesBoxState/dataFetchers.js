import __ from 'lodash'
import xhr from 'xhr'
import setUrlParams from '../../../lib/set-params-for-url.js'

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

module.exports = { fetchPage }
