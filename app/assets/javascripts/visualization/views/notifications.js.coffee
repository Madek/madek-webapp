Visualization.Views.Notifications = Backbone.View.extend

  initialize: -> 
    @el =  $("#notifications")

    # loading notification
    $(window).bind "worker_startes_layouting", => 
      @add "loading", "notification", "<div class='ui-preloader'></div> Graph wird berechnet... "
      remove_loading_notification = => @remove "loading"; $(window).unbind "worker_finished_layouting", remove_loading_notification
      $(window).bind "worker_finished_layouting", remove_loading_notification

    # alert when there are only media_entries 
    if @options.only_media_entries
      @add "only_media_entries", "alert", "Der Graph ist darauf spezialisiert, Beziehungen von Sets zu visualisieren. Ihre aktuell ausgewählten Inhalte enthalten keine Sets. Der Graph wird trotzdem dargestellt."

    # alert when there are a lot of nodes
    if @options.nodes.length > 1000
      @add "size_of_nodes", "alert", "Aufgrund der sehr hohen Anzahl der darzustellenden Inhalte kann die Berechnung des Graphen einige Minuten dauern."
      remove_size_alert = => @remove "size_alert"; $(window).unbind "worker_finished_layouting", remove_size_alert
      $(window).bind "worker_finished_layouting", remove_size_alert

  add: (name, type, text)->
    template = if @el.find("##{name}").length then @el.find(".#{name}") else $("<div></div>")
    template.attr "id", name
    template.addClass type
    template.html text
    if template.find(".x.icon.black").length == 0
      close = $("<div class='close x icon black' title='Mitteilung verbergen'></div>")
      close.bind "click", => @remove name
      template.append close
    @el.prepend template

  remove: (name)-> @el.find("##{name}").remove()
