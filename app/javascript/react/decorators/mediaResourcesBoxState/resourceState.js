import executeResourceMetadataLoad from './executeResourceMetadataLoad.js'

function nextResourceState(input) {
  const { event, initial, data, context, path } = input
  //console.log('nextResourceState', event, initial)

  function nextData() {
    if (initial) {
      // should be a fr*cking event!!!
      return {
        resource: context.resource,
        listMetadata: context.resource.list_meta_data ? context.resource.list_meta_data : null,
        loadingListMetadata: context.loadMetadata
      }
    }

    if (context.loadMetadata) {
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

  if (context.loadMetadata) {
    executeResourceMetadataLoad(input)
  }

  return {
    context: context,
    path: path,
    data: nextData(),
    components: {}
  }
}

module.exports = {
  nextResourceState
}
