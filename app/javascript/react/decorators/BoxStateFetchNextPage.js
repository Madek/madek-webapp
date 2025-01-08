import l from 'lodash'
import xhr from 'xhr'
import setUrlParams from '../../lib/set-params-for-url.js'

var requestId = Math.random()

module.exports = (merged, nextResourcesLength) => {
  return fetchNextPage(merged, nextResourcesLength)
}

var fetchNextPage = (merged, nextResourcesLength) => {
  let { event, trigger, initial, components, data, nextProps } = merged

  if (data.loadingNextPage && !(event.action == 'page-loaded')) {
    return
  }

  var pagination = nextProps.get.pagination

  var pageSize = nextProps.get.config.per_page

  var page = Math.ceil(nextResourcesLength / pageSize)

  var nextPage = page + 1

  var nextUrl = setUrlParams(
    nextProps.currentUrl,
    { list: { page: nextPage } },
    {
      ___sparse: JSON.stringify(l.set({}, nextProps.getJsonPath(), {}))
    }
  )

  // We compare the request id when sending started
  // with the request id when the answer arrives and
  // only process the answer when its still the same id.
  var localRequestId = requestId

  return xhr.get(
    {
      url: nextUrl,
      json: true
    },
    (err, res, body) => {
      if (requestId != localRequestId) {
        return
      }

      trigger(merged, {
        action: res.statusCode === 200 ? 'page-loaded' : 'page-load-failed',
        resources: l.get(body, nextProps.getJsonPath())
      })
    }
  )
}
