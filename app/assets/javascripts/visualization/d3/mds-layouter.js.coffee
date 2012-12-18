
# This similar to other d3 layout interfaces.  The d3 conventions collide
# somewhat with the rest of the objects in the Visualization. This results in
# a little bit of mess. In particular nodes and edges are shared with the
# graph object.
#
d3.layout.mds = ->

  # DATA ########################################################################################

  n = m = null
  needs_initialization = true
  nodes = []
  links = []
  current_pos = {x:[],y:[]}
  component_separation = null
  edge_length = add_set_set_edge_length = null
  index_id_map = null
  id_index_map = null
  A = [] # adjacency matrix
  D = [] # target distance, i.e. graph theoretic distance
  C = null # current distance matrix; distance after the last iteration
  W = [] # weight 

  mds_core = window.MDSCoreLayouter

  # EVENTS ###########################################################################################
  event = d3.dispatch("worker_computed_new_layout","new_layout_available", "worker_startes_layouting", "worker_finished_layouting")

  # FUNCTIONS ########################################################################################
  # replace some of them with those defined in mds_core

  compute_position_array = (nodes_array)->
    n = nodes_array.length
    pos_array= {x:[],y:[]}
    d = Math.ceil(Math.sqrt(n)) 
    # set current position or grid position with some jiggling
    for k in [0 .. n-1]
      i = k % d
      j = Math.floor(k / d)
      node = nodes_array[k]
      pos_array['x'][k] = node.x || (i * edge_length) + (Math.random()-0.5) / 10000000
      pos_array['y'][k] = node.y || (j * edge_length) + (Math.random()-0.5) / 10000000
    pos_array

  recompute_adjacency_matrix = ->

    A = mds_core.create_empty_nxn n

    mds_core.loop_m n, (i,j) ->
      A[i][j]= Number.POSITIVE_INFINITY
    for i in [0..n-1]
      A[i][i]= Number.POSITIVE_INFINITY

    for link in links
      i = Math.max id_index_map[link.source.id], id_index_map[link.target.id]
      j = Math.min id_index_map[link.source.id], id_index_map[link.target.id]
      A[i][j] = nodes[i].radius + nodes[j].radius + edge_length
      if nodes[i].type is 'MediaSet' and nodes[j].type is 'MediaSet'
        A[i][j] += add_set_set_edge_length
      A[j][i] = A[i][j]


  set_node_positions = (new_pos)->
    for node in nodes
      node.x = new_pos.x[id_index_map[node.id]]
      node.y = new_pos.y[id_index_map[node.id]]

  initialize = ->

    # do not proceed unless all parameters are set
    unless current_pos? and edge_length? and component_separation?
      return 

    n = nodes.length
    m = links.length

    id_index_map = {}
    index_id_map = {}
    for i in [0..n-1]
      id_index_map[nodes[i].id] = i 
      index_id_map[i]=nodes[i].id

    current_pos = compute_position_array(nodes)
    recompute_adjacency_matrix()

    # we reset the positions so a drawing can be preformed
    # from the presisted layout or the initial one
    set_node_positions(current_pos)
    event.new_layout_available({})


    # from here: dispatch to the webworker
    console.log "posting init-parameters to the worker"
    layout_web_worker.postMessage 
      initialize: 
        positions: current_pos
        edge_length: edge_length
        component_separation: component_separation
        A: A
   

  # WEB WORKER ########################################################################################
  
  window.layout_web_worker = layout_web_worker= new Worker "/assets/visualization_layout_web_worker.js"

  layout_web_worker.addEventListener 'message', (e) ->
    if e.data['layout']? 
      set_node_positions(e.data.layout.positions)
      event.worker_computed_new_layout(e.data)
      event.new_layout_available(e.data)

    if e.data['finished_layouting']
      event.worker_finished_layouting(e.data)


  # EXPORT ###########################################################################################
 
  mds = 
    nodes: (x)-> if x? then nodes = x; initialize(); mds else nodes
    links: (x)-> if x? then links = x; initialize(); mds else links 
    edge_length: (x)-> if x? then edge_length = x; initialize(); mds else edge_length
    add_set_set_edge_length: (x)-> if x? then add_set_set_edge_length = x; initialize(); mds else add_set_set_edge_length
    component_separation: (x)-> if x? then component_separation =x; initialize(); mds else component_separation
    reinitialize: -> initialize()
    start: -> 
      if current_pos? and edge_length? and component_separation?
        console.log "posting start event to the worker"
        event.worker_startes_layouting()
        layout_web_worker.postMessage(start: {})
      else
        console.log "NOT STARTING LAYOUTER, PARAMETERS ARE MISSING"


  d3.rebind(mds,event,"on")
