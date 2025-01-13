import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import BoxBatchEdit from './BoxBatchEdit.js'
import BoxRedux from './BoxRedux.js'
import setUrlParams from '../../lib/set-params-for-url.js'

import url from 'url'
import qs from 'qs'

var parseUrl = url.parse
var buildUrl = url.format
var buildQuery = qs.stringify
var parseQuery = qs.parse

module.exports = merged => {
  let { event, trigger, initial, components, data, nextProps, path } = merged

  var next = () => {
    if (nextProps.loadMetaData) {
      loadMetaData()
    }

    return {
      props: nextProps,
      path: path,
      data: {
        resource: nextResource(),
        listMetaData: nextListMetaData(),
        loadingListMetaData: nextLoadingListMetaData(),
        thumbnailMetaData: nextThumbnailMetaData()
      },
      components: {}
    }
  }

  var nextThumbnailMetaData = () => {
    if (initial) {
      return null
    }

    var thumbnailMetaData = nextProps.thumbnailMetaData
    if (thumbnailMetaData) {
      var getTitle = () => {
        if (thumbnailMetaData.title) {
          return thumbnailMetaData.title
        } else if (data.thumbnailMetaData) {
          return data.thumbnailMetaData.title
        } else {
          return null
        }
      }
      var getAuthors = () => {
        if (thumbnailMetaData.authors) {
          return thumbnailMetaData.authors
        } else if (data.thumbnailMetaData) {
          return data.thumbnailMetaData.authors
        } else {
          return null
        }
      }
      return {
        title: getTitle(),
        authors: getAuthors()
      }
    } else {
      return data.thumbnailMetaData
    }
  }

  var nextLoadingListMetaData = () => {
    if (initial) {
      return nextProps.loadMetaData
    }

    if (nextProps.loadMetaData) {
      return true
    } else if (
      event.action == 'load-meta-data-success' ||
      event.action == 'load-meta-data-failure'
    ) {
      return false
    } else {
      return data.loadingListMetaData
    }
  }

  var nextListMetaData = () => {
    if (initial) {
      return nextProps.resource.list_meta_data ? nextProps.resource.list_meta_data : null
    }

    if (nextProps.resetListMetaData) {
      return null
    } else if (event.action == 'load-meta-data-success') {
      return event.json
    } else {
      return data.listMetaData
    }
  }

  var nextResource = () => {
    if (initial) {
      return nextProps.resource
    }

    return data.resource
  }

  var sharedLoadMetaData = ({ success, error }) => {
    var currentQuery = parseQuery(parseUrl(window.location.toString()).query)

    var getResourceUrl = () => {
      if (initial) {
        return nextProps.resource.list_meta_data_url
      } else {
        return data.resource.list_meta_data_url
      }
    }

    var parsedUrl = parseUrl(getResourceUrl(), true)
    delete parsedUrl.search

    var url = setUrlParams(buildUrl(parsedUrl), currentQuery)

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

  var loadMetaData = () => {
    sharedLoadMetaData({
      success: json => {
        trigger(merged, { action: 'load-meta-data-success', json: json })
      },
      error: () => trigger(merged, { action: 'load-meta-data-failure' })
    })
  }

  return next()
}
