class MediaSetsController
  
  constructor: (options)->
    @highlightedResources = options.highlightedResources
    @highlights_el = $("#media_set_highlights")
    @layout = if options.layout.length then options.layout else "grid"
    do @delegateEvents
    do @render
    do @setLayout if @layout?

  setLayout: => 
    $("#content_body_set #children").removeClass("grid").removeClass("list").removeClass("miniature")
    $("#content_body_set #children").addClass(@layout)

  delegateEvents: =>
    @highlights_el.find(".inner img").load => do alignHighlights
    $(".action_menu:first .saves_display_settings").bind "click", @saveDisplaySettings

  render: =>
    for resource in @highlightedResources.media_resources
      metaData = MetaDatum.flatten resource.meta_data
      resource = $.extend resource, metaData
      @highlights_el.find(".inner").append $.tmpl "tmpl/media_resource/highlight", resource

  alignHighlights: =>
    # set the width of the inner container
    max_width = _.reduce @highlights_el.find(".inner .highlight"), ((mem, el)-> mem+$(el).outerWidth()), 0
    @highlights_el.find(".inner").outerWidth max_width+@highlights_el.find(".inner").outerWidth()-@highlights_el.find(".inner").width() + 20 # 20 as security spacer
    # scroll to the center
    @highlights_el.find(".container").scrollLeft((@highlights_el.find(".inner").outerWidth()-@highlights_el.find(".container").outerWidth())/2)

  saveDisplaySettings: (e)=>
    do e.preventDefault
    settings =
      sorting: $("#bar .sort a.active").attr("class").replace(" active", "")
      layout: $("#children").attr("class").replace("media_resources index ", "")
    $.ajax
      url: "#{window.location.pathname}/settings"
      type: "POST"
      data: settings
      beforeSend: =>
        $(e.currentTarget).find(".icon").attr("class", "loading icon")
      success: =>
        $(e.currentTarget).find(".icon").attr("class", "snag icon")
        $(e.currentTarget).closest(".action_menu").bind "mouseout", @recoverIcon

  recoverIcon: (e)=>
    $(e.currentTarget).find(".saves_display_settings .icon").attr("class", "display icon")

window.App.MediaSets = MediaSetsController