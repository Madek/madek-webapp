import executeResourceMetadataLoad from './executeResourceMetadataLoad.js'

function nextResourceState(input) {
  const { event, initial, data, nextProps, path } = input
  //console.log('nextResourceState', event, initial)

  function nextData() {
    if (initial) {
      // should be a fr*cking event!!!
      return {
        resource: nextProps.resource,
        listMetadata: nextProps.resource.list_meta_data ? nextProps.resource.list_meta_data : null,
        loadingListMetadata: nextProps.loadMetadata
      }
    }

    if (nextProps.loadMetadata) {
      // should be a fr*cking event!!!
      return { ...data, loadingListMetadata: true }
    }

    switch (event.action) {
      case 'load-meta-data-success':
        return { ...data, listMetadata: event.json, loadingListMetadata: false }
      case 'load-meta-data-failure':
        return { ...data, loadingListMetadata: false }
      case undefined:
        return data
      default:
        throw new Error(`unsupported action ${event.action}`)
    }
  }

  if (nextProps.loadMetadata) {
    executeResourceMetadataLoad(input)
  }

  return {
    props: nextProps,
    path: path,
    data: nextData(),
    components: {}
  }
}

module.exports = {
  nextResourceState
}
