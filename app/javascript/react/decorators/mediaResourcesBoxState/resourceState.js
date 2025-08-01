import { fetchListMetadata } from './dataFetchers.js'

function nextResourceState({ handle, data, context, event, triggerEvent }) {
  function nextData() {
    if (context.loadMetadata) {
      // should be a fr*cking event!!!
      return { ...data, loadingListMetadata: true }
    }

    switch (event.action) {
      case 'init-resource':
        return {
          resource: event.resource,
          listMetadata: event.resource.list_meta_data,
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
      event.action === 'init-resource'
        ? event.resource.list_meta_data_url
        : data.resource.list_meta_data_url

    fetchListMetadata({
      resourceUrl,
      onFetched: ({ success, json }) => {
        if (success) {
          triggerEvent(handle, { action: 'load-meta-data-success', json: json })
        } else {
          triggerEvent(handle, { action: 'load-meta-data-failure' })
        }
      }
    })
  }

  return {
    context: context,
    handle: handle,
    data: nextData(),
    components: {}
  }
}

module.exports = {
  nextResourceState
}
