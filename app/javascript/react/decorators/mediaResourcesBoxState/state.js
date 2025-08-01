import __ from 'lodash'
import { initializeResourceState, nextResourceState } from './resourceState.js'
import { fetchPage } from './dataFetchers.js'

function initializeState({ initialResources }) {
  return nextState({
    events: [{ event: { action: 'init', resources: initialResources } }]
  })
}

function nextState({
  state = { data: {}, components: {} },
  context = {},
  events = [],
  triggerEvent
}) {
  const { data } = state
  const { event, components } = mergeEventsIntoState(state, events)
  const action = event ? event.action : undefined

  console.log('root action', action)

  function nextResources() {
    function determineUuidsOfListMetadataToLoad() {
      if (context.layout !== 'list') {
        return {}
      }

      // 1) resource states already present, but missing list metadata (and loading never started)
      function uuidsFromExistingState() {
        return __.filter(components.resources, r => {
          return !r.data.listMetadata && !r.data.loadingListMetadata
        }).map(r => r.data.resource.uuid)
      }

      // 2) resources introduced in the current cycle, but delivered without list metadata
      function uuidsFromNewResources() {
        if (action === 'init') {
          return __.filter(event.resources, r => !r.list_meta_data).map(r => r.uuid)
        } else if (action == 'page-loaded') {
          return __.filter(event.resources, r => !r.list_meta_data).map(r => r.uuid)
        } else {
          return []
        }
      }

      const runningFetches = __.filter(components.resources, r => r.data.loadingListMetadata)
      const maxNewFetchesCount = 10 - runningFetches.length

      const uuids = __.concat(uuidsFromExistingState(), uuidsFromNewResources())
      const uuidsToLoad = __.slice(uuids, 0, maxNewFetchesCount)

      return __.fromPairs(__.map(uuidsToLoad, uuid => [uuid, uuid]))
    }

    const uuidsToLoadMetadataFor = determineUuidsOfListMetadataToLoad()

    function getNextResourceState(resourceState) {
      const resource = resourceState.data.resource
      const mustLoad = Boolean(uuidsToLoadMetadataFor[resource.uuid])
      const implicitLoadEvent = mustLoad ? { action: 'load-meta-data' } : undefined
      return nextResourceState({
        event: resourceState.event || implicitLoadEvent,
        triggerEvent: triggerEvent,
        data: resourceState.data,
        handle: resourceState.handle
      })
    }

    function getInitialResourceState(resource, index) {
      return initializeResourceState({
        handle: ['resources', index],
        resource
      })
    }

    switch (action) {
      case 'init':
        return __.map(event.resources, (r, i) => getInitialResourceState(r, i))
      case 'force-load-next-page':
        return []
      case 'page-loaded':
        if (event.currentRequestSeriesId === data.currentRequestSeriesId) {
          const n = components.resources.length
          return __.concat(
            __.map(components.resources, rs => getNextResourceState(rs)),
            __.map(event.resources, (r, i) => getInitialResourceState(r, n + i))
          )
        } else {
          // ignore newly loaded resources when they come from an expired request series
          // (e.g. when sorting was changed while resources where still loading)
          return __.map(components.resources, rs => getNextResourceState(rs))
        }
      default:
        return __.map(components.resources, rs => getNextResourceState(rs))
    }
  }

  function nextData() {
    if (!event) {
      return data
    }
    switch (event.action) {
      case 'init':
        return { loadingNextPage: false, selectedResources: null, currentRequestSeriesId: null }
      case 'mount':
        return {
          ...data,
          selectedResources: [],
          currentRequestSeriesId: event.currentRequestSeriesId
        }
      case 'load-next-page':
        return { ...data, loadingNextPage: true }
      case 'force-load-next-page':
        return {
          ...data,
          loadingNextPage: true,
          currentRequestSeriesId: event.currentRequestSeriesId
        }
      case 'page-loaded':
        return { ...data, loadingNextPage: false }
      case 'page-load-failed':
        return { ...data }

      // selection
      case 'toggle-resource-selection':
        return {
          ...data,
          selectedResources: toggleResourceSelection(
            data.selectedResources,
            event.resourceUuid,
            components.resources
          )
        }
      case 'select-resources':
        return {
          ...data,
          selectedResources: selectResources(
            data.selectedResources,
            event.resourceUuids,
            components.resources
          )
        }
      case 'unselect-resources':
        return {
          ...data,
          selectedResources: unselectResources(data.selectedResources, event.resourceUuids)
        }

      case 'fetch-list-metadata':
        // no action on root state but on components.resources
        return data

      default:
        throw new Error(`unsupported action ${event.action}`)
    }
  }

  const resources = nextResources()

  if ((action == 'load-next-page' || action == 'force-load-next-page') && !data.loadingNextPage) {
    const currentPage = Math.ceil(resources.length / context.pageSize)
    fetchPage({
      currentUrl: context.currentUrl,
      sparsePath: context.getJsonPath(),
      page: currentPage + 1,
      onFetched: ({ success, resources }) => {
        triggerEvent(undefined, {
          action: success ? 'page-loaded' : 'page-load-failed',
          currentRequestSeriesId: event.currentRequestSeriesId,
          resources
        })
      }
    })
  }

  return {
    data: nextData(),
    components: {
      resources
    }
  }
}

module.exports = { initializeState, nextState }

// -------------------------------- "Private" methods --------------------------------

// Some reducers (pure functions):

function toggleResourceSelection(oldSelectedResources, resourceUuid, allResources) {
  if (__.find(oldSelectedResources, sr => sr.uuid == resourceUuid)) {
    return __.reject(oldSelectedResources, sr => sr.uuid == resourceUuid)
  } else {
    return __.concat(
      oldSelectedResources,
      __.find(allResources, cr => cr.data.resource.uuid == resourceUuid).data.resource
    )
  }
}
function selectResources(oldSelectedResources, resourceUuids, allResources) {
  return __.concat(
    oldSelectedResources,
    __.map(
      resourceUuids,
      rid => __.find(allResources, cr => cr.data.resource.uuid == rid).data.resource
    )
  )
}
function unselectResources(oldSelectedResources, resourceUuids) {
  return __.reject(oldSelectedResources, sr => __.includes(resourceUuids, sr.uuid))
}

const mergeEventsIntoState = function (state, events) {
  function compactObject(o) {
    return __.fromPairs(
      __.compact(
        __.map(o, function (v, k) {
          return !v ? null : [k, v]
        })
      )
    )
  }
  const foundEvent = __.find(events, e => __.isEqual(e.handle, state.handle))

  return {
    ...state,
    components: compactObject(
      __.mapValues(state.components, function (component) {
        if (!component) {
          return null
        }
        if (Array.isArray(component)) {
          return __.map(component, function (indexedComponent) {
            return mergeEventsIntoState(indexedComponent, events)
          })
        } else {
          return mergeEventsIntoState(component, events)
        }
      })
    ),
    event: foundEvent && foundEvent.event ? foundEvent.event : undefined
  }
}
