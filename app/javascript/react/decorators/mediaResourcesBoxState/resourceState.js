import { fetchListMetadata } from './dataFetchers.js'

function nextResourceState(input) {
  const { event, data, context, path, triggerEvent } = input
  //console.log('nextResourceState', event)

  function nextData() {
    if (context.loadMetadata) {
      // should be a fr*cking event!!!
      return { ...data, loadingListMetadata: true }
    }

    switch (event.action) {
      case 'init':
        return {
          resource: context.resource,
          listMetadata: context.resource.list_meta_data ? context.resource.list_meta_data : null,
          loadingListMetadata: context.loadMetadata
        }
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
    const resourceUrl =
      event.action === 'init'
        ? context.resource.list_meta_data_url
        : data.resource.list_meta_data_url

    fetchListMetadata({
      resourceUrl,
      onFetched: ({ success, json }) => {
        if (success) {
          triggerEvent(path, { action: 'load-meta-data-success', json: json })
        } else {
          triggerEvent(path, { action: 'load-meta-data-failure' })
        }
      }
    })
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
