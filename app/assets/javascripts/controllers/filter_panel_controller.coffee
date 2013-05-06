###

FilterPanel

Controller for the FilterPanel

###

class FilterPanelController

  @currentPanel

  constructor: (options)->
    return FilterPanelController.currentPanel if FilterPanelController.currentPanel?
    FilterPanelController.currentPanel = @
    
    @toggle = $("#ui-side-filter-toggle")
    @panel = $("#ui-side-filter")
    @list = @panel.find ".ui-side-filter-list"
    @placeholder = @panel.find("#ui-side-filter-placeholder")
    @searchTerm = @panel.find("input#search_term")
    @fetch = options.fetch if options.fetch?
    @blockingLayer = App.render "media_resources/filter/blocking_layer"
    @filterReset = $("#ui-side-filter-reset")
    @baseFilter = options.baseFilter if options.baseFilter?
    @startSelectedFilter = options.startSelectedFilter if options.startSelectedFilter?
    @startSelectedFilter = undefined if JSON.stringify({}) == JSON.stringify(@startSelectedFilter)
    $(@panel).trigger "filter-initialized", @startSelectedFilter
    do @open if _.any(@startSelectedFilter) and not (JSON.stringify(@startSelectedFilter) == JSON.stringify(@baseFilter))
    do @showResetFilter if @startSelectedFilter? and not (JSON.stringify(@startSelectedFilter) == JSON.stringify(@baseFilter))
    do @plugin
    do @delegateEvents

  delegateEvents: =>
    @toggle.on "click", => do @togglePanel
    @panel.on "click", ".ui-accordion-toggle", (e)=> @toggleAccordion $(e.currentTarget)
    @panel.on "click", "[data-value]:not(.active)", (e)=> @selectFilter $(e.currentTarget)
    @panel.on "click", "[data-value].active", (e)=> @deselectFilter $(e.currentTarget)
    @panel.on "change", ".any-value", (e)=> @changeAnyValue $(e.currentTarget)
    @searchTerm.on "change, delayedChange", => do @filterChange
    @panel.on "submit", "form#search_form", (e)=> e.preventDefault(); do @filterChange
    @filterReset.on "click", => do @resetFilter

  filterChange: ->
    do @persistAllActiveToURL
    do @showResetFilter if @anyActiveFilter()
    do @blockForLoading
    do @toggleResetFilter
    do @deleteStartSelectedFilter
    $(@).trigger "filter-changed"
    $(@panel).trigger "filter-changed", do @getSelectedFilter

  deleteStartSelectedFilter: -> @startSelectedFilter = undefined

  showResetFilter: -> @filterReset.removeClass "hidden"

  hideResetFilter: -> @filterReset.addClass "hidden"

  resetFilter: ->
    for activeFilter in @panel.find(".active[data-value]")
      @removeFromURL @getFilterFor activeFilter
      $(activeFilter).removeClass "active"
    for activeAnyValue in @panel.find(".any-value:checked")
      @removeFromURL @getFilterFor activeAnyValue
      $(activeAnyValue).attr "checked", false 
    for k,v of @startSelectedFilter
      filter = {}
      filter[k] = @startSelectedFilter[k]
      @removeFromURL filter
    @searchTerm.val ""
    do @filterChange

  plugin: ->
    @searchTerm.delayedChange()

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
    uri = URI(window.location.href).removeQuery("filterpanel").addQuery("filterpanel", true)
    window.history.replaceState uri._parts, document.title, uri.toString()  
    @panel.removeClass "hidden"

  hide: ->
    uri = URI(window.location.href).removeQuery("filterpanel")
    window.history.replaceState uri._parts, document.title, uri.toString()  
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
        keyName: $(a).closest("[data-key-name]").data "key-name"
        contextName: $(a).closest("[data-context-name]").data "context-name"
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
        @list.find("[data-context-name='#{accordion.contextName}'] [data-key-name='#{accordion.keyName}'] > .ui-accordion-body")
      else
        @list.find("[data-context-name='#{accordion.contextName}'] > .ui-accordion-body")
      accordion.addClass "open"
      accordion.siblings(".ui-accordion-toggle").addClass "open"

  activateSelectedFilterElements: (selectedFilter)->
    for filterType, filter of selectedFilter
      continue if typeof filter != "object"
      for metaKey, values of filter
        for id in values.ids
          if id is "any"
            el = anyValue_el = @panel.find("[data-key-name='#{metaKey}'] .any-value")
            anyValue_el.attr "checked", true
          else
            el = terms = @panel.find("[data-key-name='#{metaKey}'] [data-value='#{id}']")
            terms.addClass "active"
          keys = el.closest "[data-key-name='#{metaKey}']"
          keys.addClass "has-active"
          contexts = el.closest "[data-context-name]"
          contexts.addClass "has-active"

  selectFilter: (item)->
    item.addClass "active"
    parentAnyValue = item.closest("[data-key-name]").find(".any-value")
    if parentAnyValue.length
      @deselectAnyValue parentAnyValue
    else
      do @filterChange

  deselectFilter: (item)=>
    filterType = item.closest("[data-filter-type]").data "filter-type"
    keyName = item.closest("[data-key-name]").data "key-name"
    @panel.find("[data-filter-type='#{filterType}'] [data-key-name='#{keyName}'] [data-value='#{item.data("value")}']").removeClass "active"
    @removeFromURL @getFilterFor item
    do @filterChange

  toggleResetFilter: ->
    if @anyActiveFilter()
      do @showResetFilter 
    else
      do @hideResetFilter

  blockForLoading: -> @list.append @blockingLayer unless @blockingLayer.parent().length

  removeFromURL: (filter)->
    uri = URI(window.location.href)
    uri.removeQuery decodeURIComponent($.param(filter)).replace /\=.*$/, ""
    window.history.replaceState uri._parts, document.title, uri.toString()

  persistAllActiveToURL: ->
    uri = URI(window.location.href)
    uri.removeQuery "search"
    uri.search "#{uri.search()}&#{$.param @getSelectedFilter()}"
    uri.normalizeSearch()
    window.history.replaceState uri._parts, document.title, uri.toString()

  anyActiveFilter: ->
    @panel.find(".active[data-value]").length or
    @panel.find(".any-value:checked").length or
    @searchTerm.val().length > 1

  getSelectedFilter: =>
    filter = {}
    if @startSelectedFilter?
      @startSelectedFilter
    else
      for selectedAnyValue in @panel.find(".any-value:checked")
        keyName = $(selectedAnyValue).closest("[data-key-name]").data "key-name"
        filterType = $(selectedAnyValue).closest("[data-filter-type]").data "filter-type"
        filter[filterType] = {} unless filter[filterType]?
        filter[filterType][keyName] = {} unless filter[filterType][keyName]?
        filter[filterType][keyName]["ids"] = ["any"]
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
      filter.search = @searchTerm.val()
      filter

  getFilterFor: (el)->
    el = $(el)
    if el.hasClass "any-value"
      @getFilterForAnyValueEl el
    else
      @getFilterForFilterEl el

  getFilterForAnyValueEl: (el)->
    keyName = el.closest("[data-key-name]").data "key-name"
    filterType = el.closest("[data-filter-type]").data "filter-type"
    filter = {}
    filter[filterType] = {}
    filter[filterType][keyName] = {ids: ["any"]}
    filter

  getFilterForFilterEl: (el)->
    filter = {}
    value = el.data "value"
    keyName = el.closest("[data-key-name]").data "key-name"
    filterType = el.closest("[data-filter-type]").data "filter-type"
    filter[filterType] = {}
    filter[filterType][keyName] = {}
    filter[filterType][keyName]["ids"] = [] unless filter[filterType][keyName]["ids"]?
    filter[filterType][keyName]["ids"].push value
    return filter

  changeAnyValue: (anyValue_el)->
    if anyValue_el.is(":checked") then @selectAnyValue(anyValue_el) else @deselectAnyValue(anyValue_el)

  selectAnyValue: (anyValue_el)->
    anyValue_el.attr "checked", true
    activeDescendantFilterItems = anyValue_el.closest("[data-key-name]").find(".active[data-value]")
    if activeDescendantFilterItems.length
      (@deselectFilter $(filterItem) for filterItem in activeDescendantFilterItems)
    else
      do @filterChange

  deselectAnyValue: (anyValue_el)->
    filterType = anyValue_el.closest("[data-filter-type]").data "filter-type"
    keyName = anyValue_el.closest("[data-key-name]").data "key-name"
    @panel.find("[data-filter-type='#{filterType}'] [data-key-name='#{keyName}'] .any-value").attr "checked", false
    @removeFromURL @getFilterFor anyValue_el
    do @filterChange

window.App.FilterPanelController = FilterPanelController
