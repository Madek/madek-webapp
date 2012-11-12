#= require hamlcoffee
#= require_self
#= require_tree ./d3
#= require_tree ./functions
#= require_tree ./layouters
#= require_tree ./controllers
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views

window.Visualization =
  Collections: {}
  Controllers: {}
  Data: {}
  Functions: {}
  Models: {}
  Modules: {}
  Objects: {}
  Routers: {}
  State: {}
  Views: {}

window.Visualization.init = (options) ->

  Visualization.Objects.notifications = notifications = new Visualization.Views.Notifications(options)

  if options.nodes.length > 1500
    unless confirm "Der Graph enthält #{options.nodes.length} Knoten. Bei mehr als 1500 Knoten kann die Berechnung sehr lange dauern und sogar das Browser-Fenster wegen mangelden Speichers zum Absturz bringen.\n\n Wollen Sie die Berechnung trotzdem starten? "
      if history.length > 1
        history.back() 
      else
        window.close()

  control_panel_model = 
    Visualization.Objects.control_panel_model = 
      new Visualization.Models.ControlPanel()

  new Visualization.Views.ControlPanel 
    model: control_panel_model

  new Visualization.Views.PopupMenu

  Visualization.Objects.graph = graph = Visualization.Models.create_graph
    control_panel_model: control_panel_model
    nodes: options.nodes
    arcs: options.arcs
    layout: options.layout
  
  Visualization.Objects.controller = visualization_controller = controller = 
    Visualization.Controllers.create_visualization_controller
      control_panel_model: control_panel_model
      graph: graph

  # now, set the parameters such that the view and the controller can listen
  # first defaults:
  control_panel_model.set 
    edge_length: 100
    add_set_set_edge_length: 0
    component_separation: 12
    node_radius: 5
    max_set_radius: 25
    show_labels: "sets_having_descendants"
  # then possibly saved parameters:
  control_panel_model.set options.control_settings

  
  Visualization.Controllers.create_persistence_controller 
    graph: graph
    control_panel_model: control_panel_model
    visualization_controller: visualization_controller
    resource_identifier: options.resource_identifier 

  graph_view = new Visualization.Views.GraphView
    graph: graph
    visualization_controller: visualization_controller
    origin_resource: options.origin_resource
  graph_view.render()

  # at last (re)start the layouter
  controller.start()

