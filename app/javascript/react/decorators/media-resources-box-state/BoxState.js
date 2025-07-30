import __ from 'lodash'
import BoxResource from './BoxResource.js'
import BoxStatePrecalculate from './BoxStatePrecalculate.js'
import BoxStateFetchNextPage from './BoxStateFetchNextPage.js'

const BoxState = merged => {
  const { event, trigger, initial, components, data, nextProps, path } = merged
  const { willFetch, todoLoadMetaData } = BoxStatePrecalculate(merged)

  const next = () => {
    if (willFetch) {
      BoxStateFetchNextPage(merged, nextResources().length)
    }

    return {
      props: nextProps,
      path: path,
      data: {
        loadingNextPage: nextLoadingNextPage(),
        selectedResources: nextSelectedResources(),
        currentRequestSeriesId:
          event.action === 'force-fetch-next-page' || event.action === 'mount'
            ? event.currentRequestSeriesId
            : data.currentRequestSeriesId
      },
      components: {
        resources: nextResources()
      }
    }
  }

  const nextSelectedResources = () => {
    if (initial) {
      return null
    }

    if (
      event.action == 'mount' &&
      __.includes(['MediaResources', 'MediaEntries', 'Collections'], nextProps.get.type)
    ) {
      return []
    } else if (event.action == 'toggle-resource-selection') {
      if (__.find(data.selectedResources, sr => sr.uuid == event.resourceUuid)) {
        return __.reject(data.selectedResources, sr => sr.uuid == event.resourceUuid)
      } else {
        return __.concat(
          data.selectedResources,
          __.find(components.resources, cr => cr.data.resource.uuid == event.resourceUuid).data
            .resource
        )
      }
    } else if (event.action == 'unselect-resources') {
      return __.reject(data.selectedResources, sr => __.includes(event.resourceUuids, sr.uuid))
    } else if (event.action == 'select-resources') {
      return __.concat(
        data.selectedResources,
        __.map(
          event.resourceUuids,
          rid => __.find(components.resources, cr => cr.data.resource.uuid == rid).data.resource
        )
      )
    } else {
      return data.selectedResources
    }
  }

  const nextLoadingNextPage = () => {
    if (initial) {
      return false
    }

    if (willFetch) {
      return true
    } else if (event.action == 'page-loaded') {
      return false
    } else {
      return data.loadingNextPage
    }
  }

  const nextResources = () => {
    const nextResourceProps = resource => {
      return {
        resource: resource,
        loadMetaData: todoLoadMetaData[resource.uuid] ? true : false,
        thumbnailMetaData: null,
        resetListMetaData: false
      }
    }

    const mapResourceState = resourceState => {
      const resource = resourceState.data.resource
      const resourceProps = nextResourceProps(resource)

      return BoxResource({
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

      return BoxResource({
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
    } else if (event.action == 'force-fetch-next-page') {
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

/**
 * Copies a tree of state nodes, assigning the events to the nodes according to their `path`.
 *
 * The child nodes are in the `components` key, structured as follows:
 * - node.components.a = componentStateA
 * - node.components.b = componentStateB
 * - node.components.c = [indexedComponentC1, indexedComponentC2, ...]
 *
 * Note that the `path` has nothing to do with the location of the nodes in the tree,
 * it is just an outside-bound value, typically an array.
 *
 * A node can also have the keys `id`, `data`, `props` which are just copied to the output
 * node (but `data` and `props` will be defaulted with `{}` when missing).
 *
 * See the example at the end of the file.
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
    id: state.id,
    data: state.data ? state.data : {},
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
    props: state.props ? state.props : {},
    event: foundEvent && foundEvent.event ? foundEvent.event : {},
    path: state.path
  }
}

/* 
// Example for `mergeEventsIntoState`:
const state = {
  path: 'p1',
  components: {
    raccoon: { path: 'p2', components: { sub: { path: 'p3' } } },
    otherAnimals: [{ path: 'p2' }]
  }
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
console.log(Object.keys(newState).toString() === 'id,data,components,props,event,path')
console.log(JSON.stringify(newState.data) === '{}')
console.log(JSON.stringify(newState.props) === '{}')
console.log(
  Object.keys(newState.components.raccoon).toString() === 'id,data,components,props,event,path'
)
console.log(
  Object.keys(newState.components.raccoon.components.sub).toString() ===
    'id,data,components,props,event,path'
)
console.log(
  Object.keys(newState.components.otherAnimals[0]).toString() ===
    'id,data,components,props,event,path'
)
*/

module.exports = {
  BoxState,
  mergeEventsIntoState
}
