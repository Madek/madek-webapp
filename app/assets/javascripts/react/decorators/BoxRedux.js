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

var mergeStateAndEvents = function(lastState, events) {

  var foundEvent = __.find(
    events,
    (e) => __.isEqual(e.path, lastState.path)
  )

  return {
    id: lastState.id,
    data: (lastState.data ? lastState.data : {}),
    components: compactObject(
      __.mapValues(
        lastState.components,


        function(v, k) {

          if(!v) {
            return null
          }

          if(Array.isArray(v)) {

            return __.map(
              v,
              function(vi, i) {

                var componentsArrayChild = function(lastState, k, i) {
                  return (lastState && lastState.components[k] && i < lastState.components[k].length ? lastState.components[k][i] : null)
                }

                return mergeStateAndEvents(
                  componentsArrayChild(lastState, k, i),
                  events
                )
              }
            )
          }
          else {
            return mergeStateAndEvents(
              lastState.components[k],
              events
            )
          }
        }
      )
    ),
    props: (lastState.props ? lastState.props : {}),
    event: (foundEvent && foundEvent.event ? foundEvent.event : {}),
    path: lastState.path
  }
}

var mergeStateAndEventsRoot = function(lastState, events) {
  if(!lastState) {
    return null
  } else {
    return mergeStateAndEvents(lastState, events)
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
