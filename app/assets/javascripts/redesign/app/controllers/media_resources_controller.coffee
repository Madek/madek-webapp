###

MediaResources

Controller for MediaResources

###

class MediaResourcesController

  el: "#ui-resources-list-container"

  constructor: (options)->
    @el = $(@el)
    @list = @el.find "#ui-resources-list"
    @baseFilter = options.baseFilter if options.baseFilter?
    @layoutSwitcher = @el.find "#ui-resources-layout-switcher"
    @sorting = @el.find "#ui-resources-sorting"
    @typeFilter = @el.find "#ui-resources-type-filter"
    @startFilterParams = options.startFilterParams if options.startFilterParams?
    @filterPanel = new App.FilterPanelController
      fetch: @fetchFilter
      startSelectedFilter: options.startFilterParams
    do @switchContextInview
    do @delegateEvents
    do @initalFetch

  delegateEvents: ->
    @layoutSwitcher.on "click", "[data-vis-mode]", (e) => @switchLayout $(e.currentTarget).data("vis-mode")
    @el.on "inview", ".not-loaded.ui-resources-page", (e)=> @loadPage $(e.currentTarget)
    @sorting.on "click", "[data-sort]", (e) => @changeSorting $(e.currentTarget)
    @typeFilter.on "click", ".button", (e) => @changeTypeFilter $(e.currentTarget)
    $(@filterPanel).on "filterselected", => do @filterSelected
    @el.on "click", "#ui-all-filter-reset", => do @resetAll

  resetAll: ->
    @changeTypeFilter @typeFilter.find(".button:not([data-type])")
    do @filterPanel.resetFilter

  filterSelected: ->
    do @resetForLoading
    do @initalFetch

  loadPage: (page_el)->
    page_el.removeClass "not-loaded"
    data = do @getRequestData
    data.page = page_el.data "page"
    App.MediaResource.fetch data, (media_resources, response)=>
      page = App.render "media_resources/page", response.pagination
      page.find(".ui-resources-page-items").append App.render "media_resources/media_resource", media_resources
      page_el.replaceWith page

  loadContext: (e)->
    target = $(e.currentTarget)
    media_resource_id = target.closest("[data-id]").data "id"
    context = target.data("context")
    data = 
      ids: [media_resource_id] 
      with: 
        meta_data: 
          meta_context_names: [context]
    App.MediaResource.fetch data, (media_resources)=> 
      target.html App.render "media_resources/meta_data_list_block", media_resources[0].meta_data.rawWithNamespace()
  
  changeSorting: (target_el)->
    list_el = $(target_el).closest ".ui-drop-item"
    @sorting.find(".active").removeClass "active hidden"
    list_el.addClass "active hidden"
    @sorting.find(".dropdown-toggle .ui-text").html target_el.html()
    sort = target_el.data "sort"
    window.history.pushState document.title, document.title, URI(window.location.href).removeQuery("sort").addQuery("sort", sort).toString()
    do @resetForLoading
    do @initalFetch

  changeTypeFilter: (target_el)->
    @typeFilter.find(".active").removeClass "active"
    target_el.addClass "active"
    type = target_el.data("type")
    if type?
      window.history.pushState document.title, document.title, URI(window.location.href).removeQuery("type").addQuery("type", type).toString()  
    else
      window.history.pushState document.title, document.title, URI(window.location.href).removeQuery("type").toString()
    do @resetForLoading
    do @initalFetch

  resetForLoading: -> 
    @list.html App.render "media_resources/loading_list"

  switchLayout: (visMode)->
    @layoutSwitcher.find("[data-vis-mode]").removeClass "active"
    @layoutSwitcher.find("[data-vis-mode='#{visMode}']").addClass "active"
    @list.removeClass "miniature grid list"
    @list.addClass visMode
    do @switchContextInview
    window.history.pushState document.title, document.title, URI(window.location.href).removeQuery("layout").addQuery("layout", visMode).toString()
    
  switchContextInview: ->
    if @getCurrentVisMode() is "list"
      @el.on "inview", ".not-loaded[data-context]", @loadContext
    else
      @el.off "inview", ".not-loaded[data-context]", @loadContext

  initalFetch: ->
    data = do @getRequestData
    @initialFetchAjax.abort() if @initialFetchAjax?
    @list.trigger "start-inital-fetch"
    @initialFetchAjax = App.MediaResource.fetch data, (media_resources, response)=>
      App.currentFilter = response.current_filter
      if response.pagination.total == 0
        @list.html App.render "media_resources/no_results", {}, {filterReset: @anySelectedFilter()}
      else
        page = App.render "media_resources/page", response.pagination
        page.find(".ui-resources-page-items").append App.render "media_resources/media_resource", media_resources
        @list.html page
        if response.pagination.total_pages > 1
          for page in [2..response.pagination.total_pages]
            @list.append App.render "media_resources/page", $.extend true, response.pagination, {page: page, not_loaded: true}
      if response.filter?
        @filterPanel.update response.filter 
      @list.trigger "render-inital-fetch"

  fetchFilter: =>
    data = @getRequestData true
    $.extend true, data, {with_filter: "only"}
    @fetchFilterAjax.abort() if @fetchFilterAjax?
    @fetchFilterAjax = App.MediaResource.fetch data, (media_resources, response)=> 
      @filterPanel.update response.filter, response.current_filter

  getRequestData: (withoutDefault)->
    data = {}
    $.extend true, data, App.MediaResourcesController.DEFAULT_WITH unless withoutDefault
    $.extend true, data, {with_filter: true} if @filterPanel.isOpen()
    if @startFilterParams?
      $.extend true, data, @startFilterParams
      delete @startFilterParams
    $.extend true, data, {sort: @getCurrentSorting()}
    $.extend true, data, {type: @getCurrentTypeFilter()}
    $.extend true, data, @filterPanel.getSelectedFilter()
    $.extend true, data, @baseFilter
    data

  getCurrentSorting: -> @sorting.find(".ui-drop-item.active [data-sort]").data "sort"

  getCurrentTypeFilter: -> @typeFilter.find(".active").data("type") if @typeFilter.find(".active").data("type")?

  getCurrentVisMode: -> @layoutSwitcher.find(".active").data "vis-mode"

  anySelectedFilter: ->
    !!@getCurrentTypeFilter() or
    @filterPanel.anyActiveFilter()

  @DEFAULT_WITH: 
    with: 
      media_type: true
      is_public: true
      is_private: true
      is_editable: true
      is_manageable: true
      is_favorite: true
      meta_data:
        meta_context_names: ["core"]
      image:
        as: "base64"
        size: "medium"

  @PAGESIZE= 36 
  @PAGESIZE_ARRAY = [1..@PAGESIZE]

  @toggleFavor: (toggle_el)->
    toggle_el = toggle_el.find(".ui-thumbnail-action-favorite") unless toggle_el.is ".ui-thumbnail-action-favorite"
    container = toggle_el.closest("[data-id]")
    mr = new App.MediaResource {id: container.data("id")}
    toggle_el.toggleClass "active"
    if toggle_el.hasClass "active"
      container.find(".ui-thumbnail-action-favorite").addClass "active"
      mr.favor()
    else
      container.find(".ui-thumbnail-action-favorite").removeClass "active"
      mr.disfavor()

  @delete: (container)->
    container = $(container)
    mr = new App.MediaResource {id: container.data("id"), title: container.data("title")}
    dialog = App.render "media_resources/delete_dialog", {media_resource: mr}
    dialog.find(".primary-button").bind "click", (e)-> 
      e.preventDefault()
      mr.delete()
      if container.data("redirect_on_delete")?
        dialog.remove()
        window.location.pathname = "/"
      else
        dialog.bind "hidden", -> setTimeout (-> container.remove()), 300
        dialog.modal("hide")
      return false
    App.modal dialog

window.App.MediaResourcesController = MediaResourcesController

jQuery ->
  $("[data-favor-toggle]").live "click", -> MediaResourcesController.toggleFavor $(this)
  $("[data-delete-action]").live "click", -> MediaResourcesController.delete $(@).closest("[data-id]")