#= require underscore/underscore.js
#= require visualization/layouters/mds_core.js

self.mds_core = MDSCoreLayouter

self.state = 
  needs_initialization: false
  is_layouting: false
  threshold: 1/Math.pow(10,5)
  continue: true

self.initialize = ->
  state = self.state
  state.iteration_count = 0
  state.C = mds_core.distance_matrix(state.positions)
  state.D = mds_core.floyd_warshall state.A
  state.D = mds_core.replace_infinite_values state.D,state.edge_length,state.component_separation
  state.W = mds_core.weight_matrix state.D
  state.stress = Number.MAX_VALUE
  state.needs_initialization = false


self.stress_improvement = (prev_stress, stress) ->
  if prev_stress == 0
    0
  else
    (prev_stress - stress) / prev_stress


self.layout = ->

  unless state.component_separation? and state.edge_length? and state.positions? and state.A?
    throw "uninitialized parameters" 

  state.is_layouting = true

  if self.state.needs_initialization
    self.initialize()

  prev_stress = state.stress
  state.iteration_count++
  state.positions = mds_core.compute_new_layout(state.C,state.D,state.W,state.positions)
  state.C = mds_core.distance_matrix(state.positions)
  state.stress = mds_core.stress(state.C,state.D)
  state.stress_improvement = self.stress_improvement(prev_stress,state.stress)
  state.continue = false  if state.stress_improvement <= state.threshold

  self.postMessage
    layout: _.pick(state,['stress','stress_improvement','positions','continue','iteration_count'])

  if state.continue
    setTimeout self.layout, 10
  else
    state.is_layouting = false
    self.postMessage
      finished_layouting: true    


self.onmessage = (event)->

  if event.data['initialize']?
    _.extend(self.state,event.data['initialize'])
    self.state.needs_initialization = true

  if event.data['start']?
    unless state.is_layouting
      state.continue = true
      layout()

  if event.data['stop']?
    self.state.continue = false

