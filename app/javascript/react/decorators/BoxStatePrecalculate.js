import l from 'lodash'

module.exports = merged => {
  let { event, initial, components, nextProps } = merged

  var todoLoadMetaData = () => {
    if (nextProps.get.config.layout != 'list') {
      return {}
    }

    var alreadyLoadingCount = () => {
      return l.filter(components.resources, r => {
        return (
          r.data.loadingListMetaData &&
          !(r.event.action == 'load-meta-data-success') &&
          !(r.event.action == 'load-meta-data-failure')
        )
      }).length
    }

    var availableCount = () => {
      return 10 - alreadyLoadingCount()
    }

    var needLoading = () => {
      return l.filter(components.resources, r => {
        return (
          !r.data.listMetaData &&
          !r.data.loadingListMetaData &&
          !(r.event.action == 'load-meta-data-success')
        )
      })
    }

    var existingUuidsToLoad = () => {
      return l.map(needLoading(), r => r.data.resource.uuid)
    }

    var additionalOnes = () => {
      if (initial) {
        return l.filter(nextProps.get.resources, r => !r.list_meta_data)
      } else if (event.action == 'page-loaded') {
        return l.filter(event.resources, r => !r.list_meta_data)
      } else {
        return []
      }
    }

    var newUuidsToLoad = () => {
      return l.map(additionalOnes(), r => r.uuid)
    }

    var uuidsToLoad = () => {
      return l.slice(l.concat(existingUuidsToLoad(), newUuidsToLoad()), 0, availableCount())
    }

    return l.fromPairs(l.map(uuidsToLoad(), uuid => [uuid, uuid]))
  }

  return {
    willFetch: event.action == 'fetch-next-page' || event.action == 'force-fetch-next-page',
    todoLoadMetaData: todoLoadMetaData()
  }
}
