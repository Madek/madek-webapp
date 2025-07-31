import l from 'lodash'
import xhr from 'xhr'
import setUrlParams from '../../../lib/set-params-for-url.js'

module.exports = (input, nextResourcesLength) => {
  const { event, trigger, nextProps } = input

  const pageSize = nextProps.get.config.per_page

  const page = Math.ceil(nextResourcesLength / pageSize)

  const nextPage = page + 1

  const nextUrl = setUrlParams(
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
