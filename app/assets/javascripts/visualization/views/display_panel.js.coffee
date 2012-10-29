Visualization.Views.DisplayPanel = Backbone.View.extend

  template: JST['visualization/templates/display_panel']

  initialize: ->
    @el =  $("#controls .display_panel")
    @render()

  delegateEvents: ->
    @el.bind "click", => @onClick()

  onClick: ->
    if @el.is ".active"
      @deactivate()
    else
      @activate()

  activate: ->
    @el.addClass "active"
    $("#visualization").addClass "showInformations"

  deactivate: ->
    @el.removeClass "active"
    $("#visualization").removeClass "showInformations"

  render: -> $(@el).html @template