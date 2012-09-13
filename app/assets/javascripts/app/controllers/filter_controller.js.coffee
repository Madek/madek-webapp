class FilterController
  
  @setup: (options)->
    @filter = undefined
    @el = if options? and options.el? then options.el else $("#filter_area")
    @params = if options? and options.params? then options.params else {}
    @onChange = if options? and options.onChange? then options.onChange else (=>)
    do @render
    do @setupPositioning
    do @setupSearch
    do @delegateFilterPanelEvents
    do @blockForLoading if options.start_open_filter
  
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

  @updateSearchPage: =>
    uri = new Uri(window.location.search)
    if uri.getQueryParamValues("search").length
      $("#filter_search").val @searchInput.val()
      newUrl = uri.replaceQueryParam "search", @searchInput.val()
      window.history.pushState({}, window.document.title, newUrl)
      @currentSearch = window.location.search
      $("#bar h1 small").html $("#bar h1 small").text().replace(/".*"/, "\"#{@searchInput.val()}\"") if $("#bar .icon.search").length
      for link in $("#bar a")
        link = $(link)
        href = link.attr("href")
        uri = new Uri href
        if uri.getQueryParamValues("search").length
          uri.replaceQueryParam "search", @searchInput.val()
          link.attr "href", uri.toString()

  @setupPositioning: =>
    @startOffsetTop = $("header:first").height()
    @el.css "top", @startOffsetTop
    do @repositioning
    $(window).bind "scroll", => do @repositioning

  @delegateFilterPanelEvents: =>
    @el.find(".panel>h3").bind "click", (e)=>
      if @el.is ":not(.open)" then do @open else do @close

  @open: =>
    @el.addClass "open"
    if $("#content_body_set").length
      $("#content_body_set").addClass "search"
    else
      $("section.media_resources").addClass "search"
    do @fetch unless @filter?

  @fetch: =>
    $.ajax
      url: window.location 
      type: 'GET'
      data: {format: 'json', with_filter: "only"}
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
    @blocks = @panel.find(".blocks")
    @el.html @panel
  
  @update: (new_filter)=>
    if @filter?
      # collect all selected terms
      selectedTerms = {}
      _.each @blocks.find("input:checked"), (term)->
        term = $(term)
        selectedTerms[term.closest(".block").tmplItem().data.name]?= []
        selectedTerms[term.closest(".block").tmplItem().data.name].push term.tmplItem().data.id
      openBlocks = _.map @el.find(".block.open"), (block) ->
        name: $(block).tmplItem().data.name
        scrollTop: $(block).find(".content").scrollTop()
      # disable all filter terms that are not anymore in filter
      _.each @filter, (block)->
        updatedFilterBlock = _.find new_filter, (updatedBlock) -> block.name == updatedBlock.name
        _.each block.terms, (term)->
          updatedTerm = _.find updatedFilterBlock.terms, ((t)-> t.id == term.id) if updatedFilterBlock?
          if updatedTerm?
            term.selected = if selectedTerms[block.name]? and _.include(selectedTerms[block.name],term.id) then true else false
            term.disabled = false
            term.count = updatedTerm.count
          else
            term.disabled = true unless block.filter_logic == "OR"
    else
      @filter = new_filter
    @blocks.html $.tmpl "app/views/filter/block", @filter
    _.each openBlocks, (block)=> @blocks.find("[data-filter_name='#{block.name}']").addClass("open").find(".content").scrollTop(block.scrollTop)
    do @delegateBlockEvents
    do @unblockAfterLoading
      
  @filterContent: =>
    do @updateSearchPage
    do @blockForLoading
    @onChange @computeParams()

  @delegateBlockEvents: =>
    @blocks.find("input").bind "change", (e)=> 
      do @filterContent
    @blocks.find("h3").bind "click", (e)=>
      block = $(e.currentTarget).closest(".block")
      if block.is ".open"
        block.removeClass "open"
      else
        block.addClass "open"
      if (@el.height() + parseInt(@el.css("top")) + $(".task_bar").height()) > $(window).height()
        @el.find(".block.open").removeClass("open")
        $(e.currentTarget).closest(".block").toggleClass "open"

  @blockForLoading: =>
    @blockingLayer ?= $("<div class='blocking_layer'></div>")
    @blocks.append @blockingLayer unless @blocks.find(".blocking_layer").length
    @el.find("h3 .icon").removeAttr("class").addClass("loading white icon")

  @unblockAfterLoading: =>
    @el.find("h3 .icon").removeAttr("class").addClass("filter icon")
    #@blockingLayer.detach()

  @repositioning: =>
    if @startOffsetTop-$(window).scrollTop() >= 1
      @el.css "top", @startOffsetTop-$(window).scrollTop()
    else
      @el.css "top", 1
      
  @computeParams: =>
    filter = {}
    _.each @blocks.find("input:checked"), (term)->
      term = $(term)
      block = term.closest(".block")
      filter_name = block.data("filter_name")
      if filter_name?
        filter_type = block.data("filter_type")
        filter[filter_type] ?= {}
        filter[filter_type][filter_name] ?= {}
        filter[filter_type][filter_name]['ids'] ?= []
        filter[filter_type][filter_name]['ids'].push term.val()
      else
        # consider later (e.g. image)
    filter["search"] = @searchInput.val() if @searchInput.val().length
    return filter
      
  
window.App.Filter = FilterController