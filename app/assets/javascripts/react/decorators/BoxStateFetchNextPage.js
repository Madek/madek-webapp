import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.coffee'
import BoxBatchEdit from './BoxBatchEdit.js'
import setUrlParams from '../../lib/set-params-for-url.coffee'
import BoxResource from './BoxResource.js'
import BoxRedux from './BoxRedux.js'
import qs from 'qs'
import BoxStatePrecalculate from './BoxStatePrecalculate.js'
import BoxStateApplyMetaData from './BoxStateApplyMetaData.js'

var requestId = Math.random()

module.exports = (merged, nextResourcesLength) => {
  return fetchNextPage(merged, nextResourcesLength)
}

var fetchNextPage = (merged, nextResourcesLength) => {

  let {event, trigger, initial, components, data, nextProps} = merged


  if(data.loadingNextPage && !(event.action == 'page-loaded')) {
    return
  }


  var pagination = nextProps.get.pagination


  var pageSize = nextProps.get.config.per_page

  var page = Math.ceil(nextResourcesLength / pageSize)

  var nextPage = page + 1

  var nextUrl = setUrlParams(
    nextProps.currentUrl,
    {list: {page: nextPage}},
    {
      ___sparse: JSON.stringify(
        l.set({}, nextProps.getJsonPath(), {})
      )
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

      if(requestId != localRequestId) {
        return
      }

      trigger(merged, {
        action: 'page-loaded',
        resources: l.get(body, nextProps.getJsonPath())
      })
    }
  )
}
