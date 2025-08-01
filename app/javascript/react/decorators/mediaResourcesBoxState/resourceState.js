import { fetchListMetadata } from './dataFetchers.js'

function initializeResourceState({ handle, resource }) {
  return nextResourceState({
    handle,
    event: { action: 'init-resource', resource }
  })
}

function nextResourceState({ handle, data = {}, event, triggerEvent }) {
  if (event) {
    console.log(handle.toString(), event)
  }

  function nextData() {
    if (!event) {
      return data
    }
    switch (event.action) {
      case 'init-resource':
        return {
          resource: event.resource,
          listMetadata: event.resource.list_meta_data
        }
      case 'load-meta-data':
        return { ...data, loadingListMetadata: true }
      case 'load-meta-data-success':
        return { ...data, listMetadata: event.json, loadingListMetadata: false }
      case 'load-meta-data-failure':
        return { ...data, loadingListMetadata: false }
      default:
        throw new Error(`unsupported action ${event.action}`)
    }
  }

  if (event && event.action === 'load-meta-data') {
    fetchListMetadata({
      resourceUrl: data.resource.list_meta_data_url,
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
    handle: handle,
    data: nextData()
  }
}

module.exports = { initializeResourceState, nextResourceState }
