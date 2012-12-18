# 
# This function creates an object that is responsible for persisting
# the layout, the control parameters (and possibly more in the futur)
#
# The object listens to the worker_computed_new_layout event of the visualization_controller
# and persist autonomously.
#
# It is possible to Invoke the persist() function manually though
# 

Visualization.Controllers.create_persistence_controller = (options)->
  self = {}
  throw "graph is required" unless options.graph?
  throw "control_panel_model is required" unless options.control_panel_model?
  _.extend(self,options)

  #### Persist layout ##################################################
  #
  # the layout will be saved after TIMEOUT passed; calls between the initial
  # call and the passing of the TIMEOUT will be ignored;
  #
  # This is done so we can hammer this function (e.g. by a trigger) without
  # hammering the backend and database

  self.persist = do ->

    TIMEOUT = 1000
    is_triggered = false
    is_persisting = false
    _persist = ->
      data= 
        layout: self.graph.export_layout()
        control_settings: self.control_panel_model.attributes
        resource_identifier: self.resource_identifier
      $.ajax
        type: 'PUT'
        url: "/visualization"
        data: JSON.stringify(data)
        contentType: "application/json"
        processData: false
        complete: -> # mark when we are done
          is_persisting = false
    setInterval ->
        if is_triggered and not is_persisting
          is_triggered = false
          is_persisting = true
          _persist()
      , TIMEOUT
    # return a function that sets is_triggered
    ->
      is_triggered = true

  self.graph.on "worker_computed_new_layout", (e)-> self.persist()
  self.control_panel_model.on "change", (e)-> self.persist()

  # return the object (though there is no point in using it!)
  self

