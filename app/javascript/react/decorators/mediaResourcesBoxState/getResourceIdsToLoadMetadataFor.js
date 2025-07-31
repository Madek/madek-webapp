import __ from 'lodash'

module.exports = input => {
  let { event, initial, components, nextProps } = input

  if (nextProps.get.config.layout != 'list') {
    return {}
  }

  var alreadyLoadingCount = () => {
    return __.filter(components.resources, r => {
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
    return __.filter(components.resources, r => {
      return (
        !r.data.listMetaData &&
        !r.data.loadingListMetaData &&
        !(r.event.action == 'load-meta-data-success')
      )
    })
  }

  var existingUuidsToLoad = () => {
    return __.map(needLoading(), r => r.data.resource.uuid)
  }

  var additionalOnes = () => {
    if (initial) {
      return __.filter(nextProps.get.resources, r => !r.list_meta_data)
    } else if (event.action == 'page-loaded') {
      return __.filter(event.resources, r => !r.list_meta_data)
    } else {
      return []
    }
  }

  var newUuidsToLoad = () => {
    return __.map(additionalOnes(), r => r.uuid)
  }

  var uuidsToLoad = () => {
    return __.slice(__.concat(existingUuidsToLoad(), newUuidsToLoad()), 0, availableCount())
  }

  return __.fromPairs(__.map(uuidsToLoad(), uuid => [uuid, uuid]))
}
