class FilterController
  
  @setup: (options)->
    @filter = undefined
    @el = if options? and options.el? then options.el else $("#filter_area")
    @onChange = if options? and options.onChange? then options.onChange else (=>)
    @options = options
    do @render
    do @setupSearch
    do @delegateFilterPanelEvents
    do @delegateSaveFilterSetEvents
    do @positioningForSetView if $("#content_body_set").length
    do @blockForLoading if options.start_with_open_filter
    do @open if options.start_with_open_filter
  
  @setupSearch: =>
    @searchInput = @el.find(".search input")
    do @setSearchValue
    @lastSearchValue = @searchInput.val()
    do @delegateSearchEvents

  @setSearchValue: => 
    uri = new Uri(window.location.search)
    if uri.getQueryParamValues("search").length
      newSearchValue = decodeURIComponent(uri.getQueryParamValues("search")[0]).replace(/\+/, " ")
      @searchInput.addClass("has_value").focus().select().val newSearchValue+" "

  @delegateSaveFilterSetEvents: =>
    $("#bar").delegate "a.save_filter_set", "click", (e)=>
      target = $(e.currentTarget)
      url = target.attr "href"
      $.ajax
        url: url
        type: "PUT"
        data: {filter: App.MediaResources.filter.current, format: "json"}
        success: => window.location = url

  @delegateSearchEvents: =>
    delayedSearchTimer = undefined
    @searchInput.bind "focus", => @searchInput.closest(".search").addClass("active")
    @searchInput.bind "blur", => @searchInput.closest(".search").removeClass("active")
    @el.find(".search button")  .bind "click", => do @filterContent
    @searchInput.bind "change", => if @searchInput.val().length then @searchInput.addClass("has_value") else @searchInput.removeClass("has_value")
    @searchInput.bind "keyup", =>
      clearTimeout delayedSearchTimer if delayedSearchTimer?
      delayedSearchTimer = setTimeout =>
        do @filterContent if @searchInput.val() != @lastSearchValue 
        @lastSearchValue = @searchInput.val()
      , 500
    @currentSearch = window.location.search
    $(window).bind "popstate", => 
      if @currentSearch != window.location.search
        do @setSearchValue
        do @filterContent
        @currentSearch = window.location.search

  @positioningForSetView: =>
    @el.offset {top: $("#content_body_set #children").offset().top}

  @updateSearchPage: =>
    uri = new Uri(window.location.search)
    if uri.getQueryParamValues("search").length
      $("#filter_search").val @searchInput.val()
      newUrl = uri.replaceQueryParam "search", @searchInput.val()
      @currentSearch = window.location.search
      $("#bar h1 small").html $("#bar h1 small").text().replace(/".*"/, "\"#{@searchInput.val()}\"") if $("#bar .icon.search").length
      for link in $("#bar a")
        link = $(link)
        href = link.attr("href")
        uri = new Uri href
        if uri.getQueryParamValues("search").length
          uri.replaceQueryParam "search", @searchInput.val()
          link.attr "href", uri.toString()

  @delegateFilterPanelEvents: =>
    @el.find(".panel>h3").bind "click", (e)=>
      if @el.is ":not(.open)" then do @open else do @close

  @open: =>
    @el.addClass "open"
    if $("#content_body_set").length
      $("#content_body_set").addClass "search"
    else
      $("section.media_resources").addClass "search"
    do @fetch if not @filter? and not @options.start_with_open_filter

  @fetch: =>
    data = JSON.parse JSON.stringify App.MediaResources.current_filter
    $.extend true, data, {format: 'json', with_filter: "only"}
    $.ajax
      url: "/media_resources.json"
      type: 'GET'
      data: data
      beforeSend: => do @blockForLoading 
      success: (data)=>
        @update data.filter

  @close: =>
    @el.removeClass "open"
    if $("#content_body_set").length
      $("#content_body_set").removeClass "search"
    else
      $("section.media_resources").removeClass "search"

  @render: => 
    @panel = $.tmpl "app/views/filter/panel"
    @inner = @panel.find(".inner")
    @el.html @panel
  
  @update: (new_filter)=>
    @filter = new_filter
    @inner.html $.tmpl "app/views/filter/context", @filter
    if App.MediaResources.filter.current.meta_data?
      for metaKey, values of App.MediaResources.filter.current.meta_data
        for id in values.ids
          keys = @el.find(".key[data-key_name='#{metaKey}']")
          keys.addClass "open"
          context = @el.find(".key[data-key_name='#{metaKey}']").closest ".context"
          context.addClass "open"
          if id is "any"
            @el.find(".key[data-key_name='#{metaKey}']>input.any").attr "checked", true
          else
            terms = @el.find(".key[data-key_name='#{metaKey}'] .term input[value='#{id}']").closest(".term")
            terms.addClass "selected"
            terms.find("input[value='#{id}']").attr "checked", true
    do @delegateBlockEvents
    do @unblockAfterLoading
      
  @filterContent: =>
    do @updateSearchPage
    do @blockForLoading
    @onChange @computeParams()

  @delegateBlockEvents: =>
    @inner.find("input").bind "change", (e)=> 
      term = $(e.currentTarget)
      key_name = term.closest(".key").data "key_name"
      @inner.find(".key[data-key_name='#{key_name}'] input[value='#{term.val()}']").attr "checked", $(term).is(":checked")
      do @filterContent
    @inner.find(".key > h3").bind "click", (e)=>
      key = $(e.currentTarget).closest(".key")
      if key.is ".open" then key.removeClass "open" else key.addClass "open"
    @inner.find(".context > h3").bind "click", (e)=>
      context = $(e.currentTarget).closest(".context")
      if context.is ".open" then context.removeClass "open" else context.addClass "open"

  @blockForLoading: =>
    @blockingLayer ?= $("<div class='blocking_layer'></div>")
    @inner.append @blockingLayer unless @inner.find(".blocking_layer").length
    @el.find("h3 .icon").removeAttr("class").addClass("loading white icon")

  @unblockAfterLoading: =>
    @el.find("h3 .icon").removeAttr("class").addClass("filter icon")
      
  @computeParams: =>
    filter = {meta_data: {}, search: {}}
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