window.Visualization.Controllers.create_visualization_controller= (options) ->

  # this will prevent that the start is triggered before all the 
  # initialization events are over
  _ready_to_start = false

  # the object we return:
  self = 
    methods: {}
    options: options
    graph: {}
    state: {running: false}
    export_layout: -> # returns the position of the nodes
    start: -> # start the layouting process
      # console.log "the start has been triggered"
      _ready_to_start = true  
      self.methods.restart_d3layouter()

  # shortcuts
  self.graph = graph = options.graph 

  _.extend(self,Backbone.Events)

  # react on panel_model change events ###################################################################
  options.control_panel_model.on "change:edge_length" , ->
    console.log "the edge_length has changed"
    d3layouter.edge_length(options.control_panel_model.get("edge_length"))
    self.methods.restart_d3layouter()

  options.control_panel_model.on "change:add_set_set_edge_length" , ->
    d3layouter.add_set_set_edge_length(options.control_panel_model.get("add_set_set_edge_length"))
    self.methods.restart_d3layouter()

  options.control_panel_model.on "change:component_separation" , ->
    d3layouter.component_separation(options.control_panel_model.get("component_separation"))
    self.methods.restart_d3layouter()

  options.graph.on "change:radii", ->
    d3layouter.reinitialize()
    self.methods.restart_d3layouter()

  # setting up the layouter ##############################################################################
  d3layouter = self.d3layouter = d3.layout.mds()

  d3layouter.nodes(graph.nodes_array).links(graph.arcs)

  self.methods.restart_d3layouter = ->
    #console.log "restart_d3layouter _ready_to_start: #{_ready_to_start}"
    if _ready_to_start
      d3layouter.start()


  # propagating events ################################################################################

  d3layouter.on "worker_computed_new_layout", (e) ->
    #console.log "event worker_computed_new_layout"
    self.trigger "worker_computed_new_layout", e
    graph.worker_computed_new_layout()
    $(window).trigger("worker_computed_new_layout")

  d3layouter.on "new_layout_available", (e) ->
    #console.log "event new_layout_available"
    self.trigger "new_layout_available", e
    graph.new_layout_available()
    $(window).trigger("new_layout_available")

  d3layouter.on "worker_finished_layouting", (e) ->
    #console.log "event worker_finished_layouting"
    self.trigger "worker_finished_layouting", e
    $(window).trigger("worker_finished_layouting")


  ######################################################################

  self

