class MediaSetsController
  
  constructor: (options)->
    @highlightedResources = options.highlightedResources
    @highlights_el = $("#media_set_highlights")
    do @delegateEvents
    do @render

  delegateEvents: =>
    @highlights_el.find(".inner img").load => do alignHighlights

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

window.App.MediaSets = MediaSetsController