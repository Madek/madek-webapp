import __ from 'lodash'
import getResourceIdsToLoadMetadataFor from './getResourceIdsToLoadMetadataFor.js'
import loadResourceMetadata from './loadResourceMetadata.js'
import loadNextPage from './loadNextPage.js'

/**
 * TODO - describe me and/or improve me
 * @param {Object} Old state (path, data, nextProps, components, initital, event, trigger)
 * @returns New state (path, data, props, components)
 */
const resolveEvents = input => {
  const { event, trigger, initial, components, data, nextProps, path } = input
  console.log('resolveEvents', event)

  const isPageLoad = event.action == 'load-next-page' || event.action == 'force-load-next-page'
  const resourceIdsToLoadMetadataFor = getResourceIdsToLoadMetadataFor(input)

  const next = () => {
    const resources = nextResources()

    if (isPageLoad && !data.loadingNextPage) {
      loadNextPage(input, resources.length)
    }

    const NEWDATA = nextData()
    console.log(NEWDATA)

    return {
      props: nextProps,
      path: path,
      data: nextData(),
      components: {
        resources
      }
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
          selectedResources: _toggleResourceSelection(
            data.selectedResources,
            event.resourceUuid,
            components.resources
          )
        }
      case 'select-resources':
        return {
          ...data,
          selectedResources: _selectResources(
            data.selectedResources,
            event.resourceUuids,
            components.resources
          )
        }
      case 'unselect-resources':
        return {
          ...data,
          selectedResources: _unselectResources(data.selectedResources, event.resourceUuids)
        }

      // other which do not mutate data
      case 'fetch-list-data':
      case undefined:
        return data

      default:
        throw new Error(`unsupported action ${event.action}`)
    }
  }

  const nextResources = () => {
    const nextResourceProps = resource => {
      return {
        resource: resource,
        loadMetaData: resourceIdsToLoadMetadataFor[resource.uuid] ? true : false,
        thumbnailMetaData: null,
        resetListMetaData: false
      }
    }

    const mapResourceState = resourceState => {
      const resource = resourceState.data.resource
      const resourceProps = nextResourceProps(resource)

      return loadResourceMetadata({
        event: resourceState.event,
        trigger: trigger,
        initial: false,
        components: resourceState.components,
        data: resourceState.data,
        nextProps: resourceProps,
        path: resourceState.path
      })
    }

    const mapResource = (resource, index) => {
      const resourceProps = nextResourceProps(resource)

      return loadResourceMetadata({
        event: {},
        trigger: trigger,
        initial: true,
        components: {},
        data: {},
        nextProps: resourceProps,
        path: __.concat([], [['resources', index]])
      })
    }

    if (initial) {
      return __.map(nextProps.get.resources, (r, i) => mapResource(r, i))
    } else if (event.action == 'force-load-next-page') {
      return []
    } else if (event.action == 'page-loaded') {
      if (event.currentRequestSeriesId === data.currentRequestSeriesId) {
        return __.concat(
          __.map(components.resources, rs => mapResourceState(rs)),
          __.map(event.resources, (r, i) => mapResource(r, components.resources.length + i))
        )
      } else {
        // ignore newly loaded resources when they come from an expired request series
        // (e.g. when sorting was changed while resources where still loading)
        return __.map(components.resources, rs => mapResourceState(rs))
      }
    } else {
      return __.map(components.resources, rs => mapResourceState(rs))
    }
  }

  return next()
}

function _toggleResourceSelection(oldSelectedResources, resourceUuid, allResources) {
  if (__.find(oldSelectedResources, sr => sr.uuid == resourceUuid)) {
    return __.reject(oldSelectedResources, sr => sr.uuid == resourceUuid)
  } else {
    return __.concat(
      oldSelectedResources,
      __.find(allResources, cr => cr.data.resource.uuid == resourceUuid).data.resource
    )
  }
}

function _selectResources(oldSelectedResources, resourceUuids, allResources) {
  return __.concat(
    oldSelectedResources,
    __.map(
      resourceUuids,
      rid => __.find(allResources, cr => cr.data.resource.uuid == rid).data.resource
    )
  )
}

function _unselectResources(oldSelectedResources, resourceUuids) {
  return __.reject(oldSelectedResources, sr => __.includes(resourceUuids, sr.uuid))
}

/**
 * Recursively copies a tree of state nodes, assigning the events to the nodes according to their `path`.
 *
 * The child nodes are in the `components` key, structured as follows:
 * - node.components.a = componentStateA
 * - node.components.b = componentStateB
 * - node.components.c = [indexedComponentStateC1, indexedComponentStateC2, ...]
 *
 * Note that the `path` has nothing to do with the location of the nodes in the tree,
 * it is just an outside-bound value, typically an array.
 *
 * Apart from `path` and `components`, each node also has `data` and `props` payload (being copied without modification).
 *
 * See the examples (mini unit tests) below this function.
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

/*
// Example for `mergeEventsIntoState`:
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

module.exports = {
  resolveEvents,
  mergeEventsIntoState
}
