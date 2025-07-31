import l from 'lodash'
import xhr from 'xhr'
import setUrlParams from '../../../lib/set-params-for-url.js'

module.exports = (input, nextResourcesLength) => {
  let { event, trigger, data, nextProps } = input

  if (data.loadingNextPage && !(event.action == 'page-loaded')) {
    return
  }

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

  return xhr.get(
    {
      url: nextUrl,
      json: true
    },
    (err, res, body) => {
      trigger(input, {
        action: res.statusCode === 200 ? 'page-loaded' : 'page-load-failed',
        currentRequestSeriesId: event.currentRequestSeriesId,
        resources: l.get(body, nextProps.getJsonPath())
      })
    }
  )
}
