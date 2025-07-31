import __ from 'lodash'
import getResourceIdsToLoadMetadataFor from './getResourceIdsToLoadMetadataFor.js'
import { nextResourceState } from './resourceState.js'
import { fetchPage } from './dataFetchers.js'

/*
This is refactored version of the old BoxState/BoxRedux-complex, but still not supercool.

It's kind of a state machine which takes "old world as input and returns "next state".
("old world" consists of "old state" + "event" + "context").

"Transforming" includes also executing side effects (i.e. data fetching).

`state` contains `components.resources` which is an array of `resourceState`
(having the same state model as `state` itself).
 */

/**
 * Transform state of the MediaResourcesBox component
 */
function nextState(input) {
  const { event, trigger, initial, components, data, nextProps, path } = input
  //console.log('nextState', event)

  function nextResources() {
    const resourceIdsToLoadMetadataFor = getResourceIdsToLoadMetadataFor(input)

    function getPropsForResource(resource) {
      return {
        resource: resource,
        loadMetadata: resourceIdsToLoadMetadataFor[resource.uuid] ? true : false
      }
    }

    /**
     * Transform pre-existing resource state
     */
    function getNextResourceState(resourceState) {
      const resource = resourceState.data.resource
      return nextResourceState({
        event: resourceState.event,
        trigger: trigger,
        initial: false,
        components: resourceState.components,
        data: resourceState.data,
        nextProps: getPropsForResource(resource),
        path: resourceState.path
      })
    }

    /**
     * Create initial state for a newly loaded resource object
     */
    function getInitialResourceState(resource, index) {
      return nextResourceState({
        event: {},
        trigger: trigger,
        initial: true,
        components: {},
        data: {},
        nextProps: getPropsForResource(resource),
        path: __.concat([], [['resources', index]])
      })
    }

    if (initial) {
      return __.map(nextProps.get.resources, (r, i) => getInitialResourceState(r, i))
    }

    switch (event.action) {
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
    if (initial) {
      return { loadingNextPage: false, selectedResources: null, currentRequestSeriesId: null }
    }
    switch (event.action) {
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

      // other which do not mutate data:
      case 'fetch-list-data':
      case undefined:
        return data

      default:
        throw new Error(`unsupported action ${event.action}`)
    }
  }

  const resources = nextResources()

  if (
    (event.action == 'load-next-page' || event.action == 'force-load-next-page') &&
    !data.loadingNextPage
  ) {
    const currentPage = Math.ceil(resources.length / nextProps.get.config.per_page)
    fetchPage({
      currentUrl: nextProps.currentUrl,
      sparsePath: nextProps.getJsonPath(),
      page: currentPage + 1,
      onFetched: ({ success, resources }) => {
        trigger(input, {
          action: success ? 'page-loaded' : 'page-load-failed',
          currentRequestSeriesId: event.currentRequestSeriesId,
          resources
        })
      }
    })
  }

  return {
    props: nextProps,
    path: path,
    data: nextData(),
    components: {
      resources
    }
  }
}

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

/**
 * Distributes `events` to the state nodes (`state.event` or `state.components.resources[n].event`),
 * matching the event's `path` against the node's.
 *
 * See the examples at the end of this file.
 */
const mergeEventsIntoState = function (state, events) {
  if (!state) {
    return null
  }

  function compactObject(o) {
    return __.fromPairs(
      __.compact(
        __.map(o, function (v, k) {
          return !v ? null : [k, v]
        })
      )
    )
  }
  const foundEvent = __.find(events, e => __.isEqual(e.path, state.path))

  return {
    path: state.path,
    data: state.data,
    props: state.props,
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
    event: foundEvent && foundEvent.event ? foundEvent.event : {}
  }
}

module.exports = {
  nextState,
  mergeEventsIntoState
}

/*
// Example for `mergeEventsIntoState`:
// (note thate `components` can contain arbitrary keys (single object or array), although the
// state machine actually only works with `components.resources` (array))
const state = {
  path: 'p1',
  components: {
    raccoon: { path: 'p2', components: { sub: { path: 'p3' } } },
    otherAnimals: [{ path: 'p2' }]
  },
  data: {},
  props: {}
}
const events = [
  { event: { action: 'plonk' }, path: 'p1' },
  { event: { action: 'plenk' }, path: 'p2' }
]
const newState = mergeEventsIntoState(state, events)
// events
console.log(newState.event.action === 'plonk')
console.log(newState.components.raccoon.event.action === 'plenk')
console.log(newState.components.otherAnimals[0].event.action === 'plenk')
// node properties
console.log(Object.keys(newState).toString() === 'path,data,props,components,event')
console.log(JSON.stringify(newState.data) === '{}')
console.log(JSON.stringify(newState.props) === '{}')
console.log(
  Object.keys(newState.components.raccoon).toString() === 'path,data,props,components,event'
)
console.log(
  Object.keys(newState.components.raccoon.components.sub).toString() ===
    'path,data,props,components,event'
)
console.log(
  Object.keys(newState.components.otherAnimals[0]).toString() === 'path,data,props,components,event'
)
 */
