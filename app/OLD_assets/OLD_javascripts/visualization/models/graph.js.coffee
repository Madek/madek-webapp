
# This represents the basic graph structure. Note, that THE D3-MDS-LAYOUTER
# SHARES THE NODES AND ARCS WITH THIS OBJECT. This is a horrible design but
# this is what d3 imposes (unless we would duplicate those structures, which
# would just be an other horrible thing to do).

Visualization.Models.create_graph = (options)->

  graph = {}

  _.extend(graph,Backbone.Events)

  options.control_panel_model.on "change:max_set_radius change:node_radius" , ->
    compute_radii()
    graph.trigger("change:radii")

  # the following two events are injected by the controller
  # this is a side-effect of how we share data with d3 
  
  graph.new_layout_available = ()->
    graph.trigger("new_layout_available")

  graph.worker_computed_new_layout = ()->
    graph.trigger("worker_computed_new_layout")

  # setting-up the graph datastructure ###################################################################
  graph.nodes_hash =  {} # hash with id's as given by the database
  graph.arcs =  []
  options.nodes.forEach (n)->
    n.children = []
    n.parents = []
    graph.nodes_hash[n.id] = n
  options.arcs.forEach (arc)->
    arc.source = graph.nodes_hash[arc.parent_id]
    arc.target = graph.nodes_hash[arc.child_id]
    graph.arcs.push arc
    graph.nodes_hash[arc.parent_id].children.push arc.child_id
    graph.nodes_hash[arc.child_id].parents.push arc.parent_id
  graph.nodes_array = d3.values(graph.nodes_hash) # for some things a sparse arrays is more convenient
  graph.N = graph.nodes_array.length
  graph.M = graph.arcs.length


  # copying saved layout ################################################################################
  console.log "copying saved layout ..."
  
  for id, coord of options.layout
    graph.nodes_hash[id]?.x = parseFloat(coord.x)
    graph.nodes_hash[id]?.y = parseFloat(coord.y)
    graph.nodes_hash[id]?.radius = parseFloat(coord.radius)


  # computing the radii ##################################################################################

  compute_radii= ->
    node_radius = options.control_panel_model.get("node_radius")
    max_radius = options.control_panel_model.get("max_set_radius")
    max_size = _.max( graph.nodes_array.map (x)-> parseFloat(x.size) ? 0 ) 
    if node_radius? and max_radius? and max_size?
      graph.nodes_array.forEach (n)->
        n.radius= 
          if n.size and max_size != 0
            max_radius * n.size / max_size + node_radius
          else
            node_radius

  compute_radii()

  graph.export_layout = ->
    layout = {}
    for id, node of graph.nodes_hash
      layout[id] = 
        x: node.x
        y: node.y
        radius: node.radius
    layout 

  graph


