import __ from 'lodash'

var nextId = 0

var compactObject = function(o) {
  return __.fromPairs(
    __.compact(
      __.map(o, function(v, k) {
        return !v ? null : [k, v]
      })
    )
  )
}

var mergeStateAndEvents = function(state, events) {
  var foundEvent = __.find(events, e => __.isEqual(e.path, state.path))

  return {
    id: state.id,
    data: state.data ? state.data : {},
    components: compactObject(
      __.mapValues(state.components, function(component) {
        if (!component) {
          return null
        }
        if (Array.isArray(component)) {
          return __.map(component, function(indexedComponent) {
            return mergeStateAndEvents(indexedComponent, events)
          })
        } else {
          return mergeStateAndEvents(component, events)
        }
      })
    ),
    props: state.props ? state.props : {},
    event: foundEvent && foundEvent.event ? foundEvent.event : {},
    path: state.path
  }
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
 *
 * PS: I don't know why it's called "Redux" ;)
 */
const mergeStateAndEventsRoot = function(state, events) {
  if (!state) {
    return null
  } else {
    return mergeStateAndEvents(state, events)
  }
}

module.exports = {
  nextId: function() {
    var ret = nextId
    nextId++
    return ret
  },

  mergeStateAndEventsRoot: mergeStateAndEventsRoot
}

/* 
// Example:
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
const newState = mergeStateAndEventsRoot(state, events)
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
