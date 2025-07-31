import __ from 'lodash'

module.exports = input => {
  let { event, initial, components, nextProps } = input

  if (nextProps.get.config.layout != 'list') {
    return {}
  }

  function alreadyLoadingCount() {
    return __.filter(components.resources, r => {
      return (
        r.data.loadingListMetadata &&
        !(r.event.action == 'load-meta-data-success') &&
        !(r.event.action == 'load-meta-data-failure')
      )
    }).length
  }

  function availableCount() {
    return 10 - alreadyLoadingCount()
  }

  function needLoading() {
    return __.filter(components.resources, r => {
      return (
        !r.data.listMetadata &&
        !r.data.loadingListMetadata &&
        !(r.event.action == 'load-meta-data-success')
      )
    })
  }

  function existingUuidsToLoad() {
    return __.map(needLoading(), r => r.data.resource.uuid)
  }

  function additionalOnes() {
    if (initial) {
      return __.filter(nextProps.get.resources, r => !r.list_meta_data)
    } else if (event.action == 'page-loaded') {
      return __.filter(event.resources, r => !r.list_meta_data)
    } else {
      return []
    }
  }

  function newUuidsToLoad() {
    return __.map(additionalOnes(), r => r.uuid)
  }

  function uuidsToLoad() {
    return __.slice(__.concat(existingUuidsToLoad(), newUuidsToLoad()), 0, availableCount())
  }

  return __.fromPairs(__.map(uuidsToLoad(), uuid => [uuid, uuid]))
}
