###

Abstract

###

class AbstractController

  constructor: (options)->
    @el = $(options.el)
    @subject = options.subject
    @abstractContainer = options.abstractContainer
    @slider = options.slider
    @max = options.totalChildren
    @cache = {}
    do @delegateEvents
    do @setupSlider

  delegateEvents: ->
    @slider.on "slide", @onSlide
    @abstractContainer.on "mouseenter", ".ui-tag-button", (e)=>
      target = $(e.currentTarget)
      target.addClass "mouseenter"
      if target.data("popover")?
        target.popover "show"
      else
        @loadPreview target
    @abstractContainer.on "mouseleave", ".ui-tag-button", -> $(this).removeClass "mouseenter"

  loadPreview: (target)->
    filter = {meta_data: {}}
    filter.meta_data[target.data("meta-datum-name")] = {ids: [target.data("meta-key-id")]}
    App.MediaResource.fetch 
      meta_data: filter.meta_data
      per_page: 3
    , (media_resources, response)=>
      content = App.render("abstracts/preview", {mediaResources: media_resources, total: response.pagination.total})
      target.popover
        html: true
        placement: "top"
        trigger: "hover"
        content: content
      target.popover "show" if target.is ".mouseenter"

  setupSlider: ->
    @slider.slider
      max: @max
      min: 1
    # add tooltip to handle
    @tooltip = App.render("abstracts/slider_tooltip", {total: @max})
    @slider.find(".ui-slider-handle").append @tooltip

  onSlide: (e, ui)=>
    @min = ui.value
    @tooltip.find(".from").html @min
    do @ajax.abort if @ajax?
    if @cache[@min]?
      @subject.abstract = @cache[@min]
      do @render
    else
      @ajax = @subject.fetchAbstract @min, (data)=>
        @cache[@min] = data
        do @render

  render: -> 
    @abstractContainer.html App.render "abstracts/abstract", {abstract: @subject.abstract}

window.App.AbstractController = AbstractController