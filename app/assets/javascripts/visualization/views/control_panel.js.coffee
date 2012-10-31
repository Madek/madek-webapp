Visualization.Views.ControlPanel = Backbone.View.extend

  template: JST['visualization/templates/control_panel']

  initialize: ->
    model = @options.model

    @setElement $("#controls .control_panel")
    @el =  $("#controls .control_panel")

    @render()

    ### labels ##########################################################
    @$("select.show_labels").change (event)=> 
      model.set("show_labels",@$("select.show_labels :selected").val())


    model.on "change:show_labels", (model,value,change_object)->
      $("select.show_labels option[value='#{value}']").attr('selected',true)
      switch value
        when "none"
          $("html").removeClass("show_labels_all")
          $("html").removeClass("show_labels_sets_having_descendants")
        when "sets_having_descendants"
          $("html").removeClass("show_labels_all")
          $("html").addClass("show_labels_sets_having_descendants")
        when "all"
          $("html").removeClass("show_labels_sets_having_descendants")
          $("html").addClass("show_labels_all")

     

    ### overlay ##########################################################

    @overlay = @el.find ".overlay"


    ### sliders ##########################################################

    sliders_conf=
      edge_length: 
        min: 10
        step: 10
        max: 200
      add_set_set_edge_length:
        min: 0
        step: 10
        max: 200
      component_separation:
        min: 2
        step: 1
        max: 20
      node_radius:
        min: 2.5
        step: 2.5
        max: 10
      max_set_radius:
        min: 0
        step: 5
        max: 50

    for name, conf of sliders_conf
      do =>
        local_name = name
        slider_def= 
          _.extend({},conf,
            change: (event,ui) ->
              $("##{local_name}_value").html(ui.value)
            slide: (event,ui) ->
              $("##{local_name}_value").html(ui.value)
            stop: (event,ui) ->
              model.set(local_name,ui.value))
       
        $("##{local_name}").slider(slider_def)
        $("##{local_name}").slider('option','value',model.get("#{local_name}"))
        model.on "change:#{local_name}", (model,value)=>
          @block()
          $("##{local_name}").slider('option','value',value)

  render: -> $(@el).html @template

  delegateEvents: ->
    $(window).bind "worker_computed_new_layout", => @unblock()

  block: -> @overlay.show()

  unblock: -> @overlay.hide()
