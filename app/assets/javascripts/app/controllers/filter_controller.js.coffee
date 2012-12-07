class FilterController
  
  constructor: (options)->
    @el = if options? and options.el? then options.el else $("#filter_area")
    @onChange = if options? and options.onChange? then options.onChange else (=>)
    if options?
      @current_filter = options.current_filter
      @start_with_open_filter = options.start_with_open_filter
    do @render
    @inner = @panel.find(".inner")
    @resetButton = @panel.find(".reset.button")
    @title = @panel.find(".h3 .text")
    do @setupSearch
    do @delegateFilterPanelEvents
    do @delegateSaveFilterSetEvents
    do @positioningForSetView if $(".content_body_set").length
    do @blockForLoading if options.start_with_open_filter
    do @open if options.start_with_open_filter
  
  setupSearch: =>
    @searchInput = @el.find(".search input")
    do @setSearchValue
    @lastSearchValue = @searchInput.val()
    do @delegateSearchEvents

  setSearchValue: => 
    uri = new Uri(window.location.search)
    if uri.getQueryParamValues("search").length
      newSearchValue = decodeURIComponent(uri.getQueryParamValues("search")[0]).replace(/\+/g, " ")
      @searchInput.addClass("has_value").focus().select().val newSearchValue+" "

  delegateSaveFilterSetEvents: =>
    $("#bar").delegate "a.save_filter_set", "click", (e)=>
      target = $(e.currentTarget)
      url = target.attr "href"
      $.ajax
        url: url
        type: "PUT"
        data: {filter: @current_filter, format: "json"}
        success: => window.location = url

  delegateSearchEvents: =>
    delayedSearchTimer = undefined
    @searchInput.bind "focus", => 
      @searchInput.select()
      @searchInput.closest(".search").addClass("active")
    @searchInput.bind "blur", => @searchInput.closest(".search").removeClass("active")
    @el.find(".search button").bind "click", =>
      do @updateSearchPage 
      do @filterContent
    @searchInput.bind "change", => if @searchInput.val().length then @searchInput.addClass("has_value") else @searchInput.removeClass("has_value")
    @searchInput.bind "keyup", =>
      clearTimeout delayedSearchTimer if delayedSearchTimer?
      delayedSearchTimer = setTimeout =>
        if @searchInput.val() != @lastSearchValue
          do @updateSearchPage
          do @filterContent
        @lastSearchValue = @searchInput.val()
      , 500

  positioningForSetView: =>
    @el.offset {top: $(".content_body_set #children").offset().top}

  updateSearchPage: =>
    uri = new Uri(window.location.search)
    if uri.getQueryParamValues("search").length
      $("#bar h1 small").html $("#bar h1 small").text().replace(/".*"/, "\"#{@searchInput.val()}\"") if $("#bar .icon.search").length
  
  delegateFilterPanelEvents: =>
    @el.find(".panel>.icon").bind "click", (e)=>
      if @el.is ":not(.open)" then do @open else do @close
    @resetButton.bind "click", =>
      @inner.find("input:checked").attr "checked", false
      do @resetButton.hide
      do @title.show
      do @filterContent

  open: =>
    @el.addClass "open"
    if $(".content_body_set").length
      $(".content_body_set").addClass "search"
    else
      $("section.media_resources").addClass "search"
    do @fetch if not @filter_contexts? and not @start_with_open_filter

  fetch: =>
    data = JSON.parse JSON.stringify @current_filter
    $.extend true, data, {format: 'json', with_filter: "only"}
    $.ajax
      url: "/media_resources.json"
      type: 'GET'
      data: data
      beforeSend: => do @blockForLoading 
      success: (data)=> @update data.filter

  close: =>
    @el.removeClass "open"
    if $(".content_body_set").length
      $(".content_body_set").removeClass "search"
    else
      $("section.media_resources").removeClass "search"

  render: => 
    @panel = $.tmpl "app/views/filter/panel"
    @el.html @panel
  
  update: (new_filter)=>
    @filter_contexts = new_filter
    @inner.html $.tmpl "app/views/filter/context", @filter_contexts
    do @resetButton.hide
    do @title.show
    for filter_type, filter of @current_filter
      continue if typeof filter != "object"
      do @resetButton.show
      do @title.hide
      for metaKey, values of filter
        for id in values.ids
          keys = @el.find(".key[data-key_name='#{metaKey}']")
          keys.addClass "open"
          context = @el.find(".key[data-key_name='#{metaKey}']").closest ".context"
          context.addClass "open"
          if id is "any"
            any = @el.find(".key[data-key_name='#{metaKey}']>.any")
            any.addClass "selected"
            @el.find(".key[data-key_name='#{metaKey}']>.any input").attr "checked", true
          else
            terms = @el.find(".key[data-key_name='#{metaKey}'] .term input[value='#{id}']").closest(".term")
            terms.addClass "selected"
            terms.find("input[value='#{id}']").attr "checked", true
            terms.closest(".key").addClass "has_selected"
    do @delegateBlockEvents
    do @unblockAfterLoading
      
  filterContent: =>
    do @blockForLoading
    @onChange @computeParams()

  delegateBlockEvents: =>
    @inner.find("input").bind "change", (e)=> 
      term = $(e.currentTarget)
      term.closest(".term").addClass "selected"
      key_name = term.closest(".key").data "key_name"
      @inner.find(".key[data-key_name='#{key_name}'] input[value='#{term.val()}']").attr "checked", $(term).is(":checked")
      do @filterContent
    @inner.find(".key > h3").bind "click", (e)=>
      key = $(e.currentTarget).closest(".key")
      if key.is ".open" then key.removeClass "open" else key.addClass "open"
    @inner.find(".context > h3").bind "click", (e)=>
      context = $(e.currentTarget).closest(".context")
      if context.is ".open" then context.removeClass "open" else context.addClass "open"

  blockForLoading: =>
    @blockingLayer ?= $("<div class='blocking_layer'></div>")
    @inner.append @blockingLayer unless @inner.find(".blocking_layer").length
    @el.find(".panel>.icon").removeAttr("class").addClass("loading white icon")

  unblockAfterLoading: =>
    @el.find(".panel>.icon").removeAttr("class").addClass("filter icon")
      
  computeParams: =>
    filter = {meta_data: {}, search: {}, permissions: {}, media_files: {}}
    _.each @inner.find("input:checked"), (term)->
      term = $(term)
      key = term.closest(".key")
      key_name = key.data("key_name")
      if key_name?
        filter_type = key.closest(".context").data("filter_type")
        filter[filter_type] ?= {}
        filter[filter_type][key_name] ?= {}
        filter[filter_type][key_name]['ids'] ?= []
        filter[filter_type][key_name]['ids'].push term.val()
      else
        # consider later (e.g. image)
    filter["search"] = _.str.trim @searchInput.val() if @searchInput.val().length
    return filter

window.App.Filter = FilterController