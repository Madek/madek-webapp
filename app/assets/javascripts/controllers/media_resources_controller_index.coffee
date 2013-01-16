###

MediaResources#Index

Controller for MediaResources Index

###

MediaResourcesController = {} unless MediaResourcesController?
class MediaResourcesController.Index

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
      baseFilter: options.baseFilter
    do @setDefaultLayout
    do @switchContextInview
    do @delegateEvents
    do @initalFetch

  delegateEvents: ->
    @layoutSwitcher.on "click", "[data-vis-mode]", (e) => @switchLayout $(e.currentTarget).data("vis-mode")
    @el.on "inview", ".not-loaded.ui-resources-page", (e)=> @loadPage $(e.currentTarget)
    @el.on "inview", "[data-group-of-ten-page]", (e)=> @enfoldGroupOfPages $(e.currentTarget)
    @sorting.on "click", "[data-sort]", (e) => @changeSorting $(e.currentTarget)
    @typeFilter.on "click", ".button", (e) => @changeTypeFilter $(e.currentTarget)
    $(@filterPanel).on "filter-changed", => do @filterChanged
    @el.on "click", "#ui-all-filter-reset", => do @resetAll

  setDefaultLayout: ->
    unless @getCurrentVisMode()?
      if sessionStorage.currentLayout?
        layout = JSON.parse sessionStorage.currentLayout
        @switchLayout layout
      else
        @layoutSwitcher.find("[data-default]").addClass "active"
    unless @getCurrentSorting()?
      @sorting.find("[data-default]").addClass "active" 

  resetAll: ->
    @changeTypeFilter @typeFilter.find(".button:not([data-type])")
    do @filterPanel.resetFilter

  filterChanged: ->
    do @resetForLoading
    do @initalFetch

  enfoldGroupOfPages: (group_el)->
    num = group_el.data "group-of-ten-page"
    placeholders = $("<div></div>")
    for page in [1..10]
      if @initalPages != 0
        page = (num * 10 - (10-@initalPages)) + page
      else
        page = 1 + page
      placeholders.append App.render "media_resources/page", {page: page, not_loaded: true, total_pages: @totalPages, total: @total}
    group_el.replaceWith placeholders.html()

  loadPage: (page_el)->
    page_el.addClass "loading"
    page_el.removeClass "not-loaded"
    data = do @getRequestData
    data.page = page_el.data "page"
    App.MediaResource.fetch data, (media_resources, response)=>
      page = App.render "media_resources/page", response.pagination
      page.find(".ui-resources-page-items").append App.render "media_resources/media_resource", media_resources
      page_el.removeClass "loading"
      page_el.replaceWith page

  loadContexts: (e)->
    mr_el = $(e.currentTarget)
    mr_el.removeClass "not-loaded-contexts"
    media_resource_id = mr_el.data "id"
    for context_el in mr_el.find("[data-context]")
      do (context_el)->
        context_el = $(context_el)
        context = context_el.data("context")
        data = 
          ids: [media_resource_id] 
          with: 
            meta_data: 
              meta_context_names: [context]
        App.MediaResource.fetch data, (media_resources)=> 
          context_el.html App.render "media_resources/meta_data_list_block", 
            {meta_data: media_resources[0].meta_data},
            {context: context}
  
  changeSorting: (target_el)->
    sort = target_el.data "sort"
    return true if sort == @getCurrentSorting()
    list_el = $(target_el).closest ".ui-drop-item"
    @sorting.find(".active").removeClass "active hidden"
    list_el.addClass "active hidden"
    @sorting.find(".dropdown-toggle .ui-text").html target_el.html()
    uri = URI(window.location.href).removeQuery("sort").addQuery("sort", sort)
    window.history.pushState uri._parts, document.title, uri.toString()
    do @resetForLoading
    @list.trigger "sorting-changed", sort
    do @initalFetch

  changeTypeFilter: (target_el)->
    @typeFilter.find(".active").removeClass "active"
    target_el.addClass "active"
    type = target_el.data("type")
    if type?
      uri = URI(window.location.href).removeQuery("type").addQuery("type", type)
      window.history.pushState uri._parts, document.title, uri.toString()  
    else
      uri = URI(window.location.href).removeQuery("type")
      window.history.pushState uri._parts, document.title, uri.toString()
    do @resetForLoading
    do @initalFetch

  resetForLoading: -> 
    @list.html App.render "media_resources/loading_list"

  switchLayout: (visMode)->
    return true if visMode == @getCurrentVisMode()
    @layoutSwitcher.find("[data-vis-mode]").removeClass "active"
    @layoutSwitcher.find("[data-vis-mode='#{visMode}']").addClass "active"
    @list.removeClass "miniature grid list"
    @list.addClass visMode
    do @switchContextInview
    uri = URI(window.location.href).removeQuery("layout").addQuery("layout", visMode)
    window.history.pushState uri._parts, document.title, uri.toString()
    @list.trigger "layout-changed", visMode
    sessionStorage.currentLayout = JSON.stringify visMode
    
  switchContextInview: ->
    if @getCurrentVisMode() is "list"
      @el.on "inview", ".not-loaded-contexts.ui-resource", @loadContexts
    else
      @el.off "inview", ".not-loaded-contexts.ui-resource", @loadContexts

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
        @totalPages = response.pagination.total_pages
        @total = response.pagination.total
        do @setupPlaceholdersPages if @totalPages > 1
      @filterPanel.update response.filter 
      @list.trigger "render-inital-fetch"

  setupPlaceholdersPages: ->
    groupsOfTen = Math.floor @totalPages/10
    @initalPages = @totalPages%10
    placeholders = $("<div></div>")
    if @initalPages > 1
      for page in [2..@initalPages]
        placeholders.append App.render "media_resources/page", {page: page, not_loaded: true, total_pages: @totalPages, total: @total}
    if groupsOfTen > 1
      for groupOfTen in [1..groupsOfTen]
        placeholders.append App.render "media_resources/group_of_ten_pages", {group: groupOfTen}
    @list.append placeholders.html()

  fetchFilter: =>
    data = @getRequestData true
    $.extend true, data, {with_filter: "only"}
    @fetchFilterAjax.abort() if @fetchFilterAjax?
    @fetchFilterAjax = App.MediaResource.fetch data, (media_resources, response)=> 
      @filterPanel.update response.filter, response.current_filter

  getRequestData: (withoutDefault)->
    data = {}
    $.extend true, data, App.MediaResourcesController.Index.DEFAULT_WITH unless withoutDefault
    $.extend true, data, {with_filter: true} if @filterPanel.isOpen()
    if @startFilterParams?
      $.extend true, data, @startFilterParams
      delete @startFilterParams
    $.extend true, data, {sort: @getCurrentSorting()}
    $.extend true, data, {type: @getCurrentTypeFilter()}
    $.extend true, data, @filterPanel.getSelectedFilter()
    $.extend true, data, @baseFilter
    # merge basefilter search term with filter panel search term
    if @baseFilter.search? and @filterPanel.getSelectedFilter().search?
      $.extend true, data, {search: @baseFilter.search + " " + @filterPanel.getSelectedFilter().search} 
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

window.App.MediaResourcesController = {} unless window.App.MediaResourcesController
window.App.MediaResourcesController.Index = MediaResourcesController.Index

jQuery ->
  $("[data-favor-toggle]").live "click", -> MediaResourcesController.Index.toggleFavor $(this)
  $("[data-delete-action]").live "click", -> MediaResourcesController.Index.delete $(@).closest("[data-id]")