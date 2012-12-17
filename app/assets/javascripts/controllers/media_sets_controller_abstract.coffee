###

MediaSets#Abstract

###

MediaSetsController = {} unless MediaSetsController?
class MediaSetsController.Abstract

  el: ".app.view-set"

  constructor: (options)->
    @el = $(@el)
    @cache = {}
    @mediaSet = new App.MediaSet @el.data()
    @abstract_el = @el.find "#ui-media-set-abstract"
    @slider_el = @el.find "#ui-media-set-abstract-slider"
    @max = options.totalChildren
    do @delegateEvents
    do @setupSlider

  delegateEvents: ->
    @slider_el.on "slide", @onSlide
    @abstract_el.on "mouseenter", ".ui-tag-button", (e)=>
      target = $(e.currentTarget)
      target.addClass "mouseenter"
      if target.data("popover")?
        target.popover "show"
      else
        @loadPreview target
    @abstract_el.on "mouseleave", ".ui-tag-button", -> $(this).removeClass "mouseenter"

  loadPreview: (target)->
    filter = {meta_data: {}}
    filter.meta_data[target.data("meta-datum-name")] = {ids: [target.data("meta-key-id")]}
    App.MediaResource.fetch 
      meta_data: filter.meta_data
      per_page: 3
    , (media_resources, response)=>
      content = App.render("media_sets/abstract/preview", {mediaResources: media_resources, total: response.pagination.total})
      target.popover
        html: true
        placement: "top"
        trigger: "hover"
        content: content
      target.popover "show" if target.is ".mouseenter"

  setupSlider: ->
    @slider_el.slider
      max: @max
      min: 1
    # add tooltip to handle
    @tooltip = App.render("media_sets/abstract/slider_tooltip", {total: @max})
    @slider_el.find(".ui-slider-handle").append @tooltip

  onSlide: (e, ui)=>
    @min = ui.value
    @tooltip.find(".from").html @min
    if @cache[@min]?
      @mediaSet.abstract = @cache[@min]
      do @render
    else
      @mediaSet.fetchAbstract @min, (data)=> 
        @cache[@min] = data
        do @render

  render: -> 
    @abstract_el.html App.render "media_sets/abstract", {abstract: @mediaSet.abstract}

window.App.MediaSetsController = {} unless window.App.MediaSetsController
window.App.MediaSetsController.Abstract = MediaSetsController.Abstract