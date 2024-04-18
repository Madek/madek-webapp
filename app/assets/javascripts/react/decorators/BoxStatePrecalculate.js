import l from 'lodash'
import BoxBatchEditInvalids from './BoxBatchEditInvalids.js'

module.exports = merged => {
  let { event, trigger, initial, components, data, nextProps } = merged

  var willFetch = () => {
    return (
      event.action == 'fetch-next-page' ||
      event.action == 'force-fetch-next-page' ||
      (event.action == 'page-loaded' &&
        components.batch.data.open &&
        components.resources.length + event.resources.length <
          nextProps.get.pagination.total_count) ||
      (components.batch &&
        components.batch.event.action == 'toggle' &&
        components.resources.length < nextProps.get.pagination.total_count)
    )
  }

  var anyResourceApply = l.filter(components.resources, r => r.event.action == 'apply').length > 0

  var willStartApply = () => {
    return (
      formsValid(merged) &&
      (event.action == 'apply' || event.action == 'apply-selected' || anyResourceApply)
    )
  }

  var anyApplyAction = () => {
    return (
      event.action == 'apply' ||
      event.action == 'apply-selected' ||
      l.find(components.resources, rs => rs.event.action == 'apply')
    )
  }

  var todoLoadMetaData = () => {
    if (
      (components.batch && components.batch.data.applyJob) ||
      nextProps.get.config.layout != 'list'
    ) {
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
          (!r.data.listMetaData ||
            (components.batch &&
              components.batch.event.action == 'apply-success' &&
              components.batch.event.resourceId == r.data.resource.uuid)) &&
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
    willFetch: willFetch(),
    willStartApply: willStartApply(),
    anyApplyAction: anyApplyAction(),
    anyResourceApply: anyResourceApply,
    todoLoadMetaData: todoLoadMetaData()
  }
}

var formsValid = merged => {
  if (merged.initial) {
    return false
  }
  return l.isEmpty(BoxBatchEditInvalids(merged.components.batch))
}
