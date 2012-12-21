###

FilterPanel

Controller for the FilterPanel

###

class FilterPanelController

  constructor: (options)->
    @toggle = $("#ui-side-filter-toggle")
    @panel = $("#ui-side-filter")
    @list = @panel.find ".ui-side-filter-list"
    @placeholder = @panel.find("#ui-side-filter-placeholder")
    @searchTerm = @panel.find("#ui-side-filter-search")
    @fetch = options.fetch if options.fetch?
    @blockingLayer = App.render "media_resources/filter/blocking_layer"
    @filterReset = $("#ui-side-filter-reset")
    @baseFilter = options.baseFilter if options.baseFilter?
    @startSelectedFilter = options.startSelectedFilter if options.startSelectedFilter?
    @startSelectedFilter = undefined if JSON.stringify({}) == JSON.stringify(@startSelectedFilter)
    do @open if _.any(@startSelectedFilter) and not (JSON.stringify(@startSelectedFilter) == JSON.stringify(@baseFilter))
    do @showResetFilter if @startSelectedFilter? and not (JSON.stringify(@startSelectedFilter) == JSON.stringify(@baseFilter))
    do @plugin
    do @delegateEvents

  delegateEvents: ->
    @toggle.on "click", => do @togglePanel
    @panel.on "click", ".ui-accordion-toggle", (e)=> @toggleAccordion $(e.currentTarget)
    @panel.on "click", "[data-value]:not(.active)", (e)=> @selectFilter $(e.currentTarget)
    @panel.on "click", "[data-value].active", (e)=> @deselectFilter $(e.currentTarget)
    @searchTerm.find("input").on "change, delayedChange", (e)=> do @search
    @filterReset.on "click", => do @resetFilter

  search: ->
    do @persistAllActiveToURL
    do @showResetFilter if @anyActiveFilter()
    do @blockForLoading
    do @toggleResetFilter
    do @deleteStartSelectedFilter
    $(@).trigger "filter-changed"

  deleteStartSelectedFilter: -> @startSelectedFilter = undefined

  showResetFilter: -> @filterReset.removeClass "hidden"

  hideResetFilter: -> @filterReset.addClass "hidden"

  resetFilter: ->
    for activeFilter in @panel.find(".active[data-value]")
      @removeFromURL @getFilterFor activeFilter
      $(activeFilter).removeClass "active"
    for k,v of @startSelectedFilter
      filter = {}
      filter[k] = @startSelectedFilter[k]
      @removeFromURL filter
    @searchTerm.find("input").val ""
    do @deleteStartSelectedFilter
    $(@).trigger "filter-changed"
    do @persistAllActiveToURL
    do @blockForLoading
    do @toggleResetFilter

  plugin: ->
    @searchTerm.find("input").delayedChange()

  toggleAccordion: (target)->
    target.toggleClass "open"
    target.siblings(".ui-accordion-body").toggleClass "open"

  togglePanel: ->
    if @toggle.is ".active"
      do @close
    else
      do @open
    do @fetch unless @filter?

  open: ->
    @toggle.addClass "active"
    do @show

  close: ->
    @toggle.removeClass "active"
    do @hide

  show: ->
    window.history.pushState document.title, document.title, URI(window.location.href).removeQuery("filterpanel").addQuery("filterpanel", true).toString()  
    @panel.removeClass "hidden"

  hide: ->
    window.history.pushState document.title, document.title, URI(window.location.href).removeQuery("filterpanel").toString()  
    @panel.addClass "hidden"

  isOpen: -> not @panel.hasClass "hidden"

  update: (filter)->
    if @placeholder?
      @placeholder.remove()
      delete @placeholder
    @filter = filter
    if @filter?
      selectedFilter = @getSelectedFilter()
      openAccordions = _.map @panel.find(".ui-accordion-body.open"), (a)->
        a = $(a)
        _return = 
          keyName: a.closest("[data-key-name]").data "key-name"
          filterType: a.closest("[data-filter-type]").data "filter-type"
      @list.html App.render "media_resources/filter/context", @filter
      @openAccordions openAccordions
      if @startSelectedFilter?
        @activateSelectedFilterElements @startSelectedFilter
        delete @startSelectedFilter
      else
        @activateSelectedFilterElements selectedFilter
    else
      @list.html App.render "preloader/filter"

  openAccordions: (accordions)->
    for accordion in accordions
      accordion = if accordion.keyName?
        @list.find("[data-filter-type='#{accordion.filterType}'] [data-key-name='#{accordion.keyName}'] > .ui-accordion-body")
      else
        @list.find("[data-filter-type='#{accordion.filterType}'] > .ui-accordion-body")
      accordion.addClass "open"
      accordion.siblings(".ui-accordion-toggle").addClass "open"

  activateSelectedFilterElements: (selectedFilter)->
    for filterType, filter of selectedFilter
      continue if typeof filter != "object"
      for metaKey, values of filter
        for id in values.ids
          terms = @panel.find("[data-key-name='#{metaKey}'] [data-value='#{id}']")
          terms.addClass "active"
          keys = terms.closest "[data-key-name='#{metaKey}']"
          keys.addClass "has-active"
          contexts = terms.closest "[data-filter-type]"
          contexts.addClass "has-active"

  selectFilter: (item)->
    item.addClass "active"
    do @deleteStartSelectedFilter
    $(@).trigger "filter-changed"
    do @persistAllActiveToURL
    do @blockForLoading
    do @toggleResetFilter

  deselectFilter: (item)->
    item.removeClass "active"
    do @deleteStartSelectedFilter
    $(@).trigger "filter-changed"
    @removeFromURL @getFilterFor item
    do @blockForLoading
    do @toggleResetFilter

  toggleResetFilter: ->
    if @anyActiveFilter()
      do @showResetFilter 
    else
      do @hideResetFilter

  blockForLoading: -> @list.append @blockingLayer unless @blockingLayer.parent().length

  removeFromURL: (filter)->
    uri = URI(window.location.href)
    uri.removeQuery decodeURIComponent($.param(filter)).replace /\=.*$/, ""
    window.history.pushState document.title, document.title, uri.toString()

  persistAllActiveToURL: ->
    uri = URI(window.location.href)
    uri.removeQuery "search"
    uri.search "#{uri.search()}&#{$.param @getSelectedFilter()}"
    uri.normalizeSearch()
    window.history.pushState document.title, document.title, uri.toString()

  anyActiveFilter: ->
    @panel.find(".active[data-value]").length or
    @searchTerm.find("input").val().length > 1

  getSelectedFilter: ->
    filter = {}
    if @startSelectedFilter?
      @startSelectedFilter
    else
      for selectedFilter in @panel.find(".active[data-value]")
        selectedFilter = $(selectedFilter)
        filterData = @getFilterFor selectedFilter
        filterKeyAlreadyExists = false
        for filterType,key of filterData
          for keyName,terms of key
            if filter[filterType]? and filter[filterType][keyName]?
              filterKeyAlreadyExists = true
              for id in terms.ids
                filter[filterType][keyName].ids.push id
        $.extend true, filter, filterData unless filterKeyAlreadyExists
      filter.search = @searchTerm.find("input").val()
      filter

  getFilterFor: (filter_el)->
    filter_el = $(filter_el)
    filter = {}
    value = filter_el.data "value"
    keyName = filter_el.closest("[data-key-name]").data "key-name"
    filterType = filter_el.closest("[data-filter-type]").data "filter-type"
    filter[filterType] = {}
    filter[filterType][keyName] = {}
    filter[filterType][keyName]["ids"] = [] unless filter[filterType][keyName]["ids"]?
    filter[filterType][keyName]["ids"].push value
    return filter

window.App.FilterPanelController = FilterPanelController