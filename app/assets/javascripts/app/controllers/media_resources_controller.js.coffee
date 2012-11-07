class MediaResourcesController
  
  constructor: (options)->
    @el = $("section.media_resources.index")
    @el.data "controller", @
    do @plugin
    @active_layout = if options.layout? then options.layout else if sessionStorage.active_layout? then sessionStorage.active_layout else "grid"
    @start_with_open_filter = options.start_with_open_filter if options.start_with_open_filter?
    @filter_panel = new App.Filter
      onChange: (filter_params)=> @initial_fetch filter_params, true
      start_with_open_filter: @start_with_open_filter
      current_filter: options.filter
    MediaResourcesController.current_sort = options.sort if options.sort?
    do @activate_layout
    do @delegate_events
    do @switch_context_fetch
    @initial_fetch {}, @start_with_open_filter
    
  plugin: ->
    new ActionMenu @el
    
  delegate_events: ->
    @el.delegate "#bar .layout a[data-type]", "click", @switch_layout 
    @el.delegate ".page[data-page]", "inview", @render_page

  activate_layout: ->
    @el.addClass @active_layout

  render_page: (e)=>
    $this = $(e.currentTarget)
    next_page = $this.data "page"
    $this.removeAttr "data-page"
    data = 
      page: next_page
    $.extend true, data, @filter_panel.current_filter
    $.extend data, {sort: App.MediaResources.current_sort}
    options =
      data: data
      success: (data)->
        display_page(data, $this)
    App.MediaResources.fetch options

  render_context: ->
    $this = $(this)
    context_name = $this.data "name"
    context_label = $this.data "label"
    $this.removeAttr "data-name"
    $this.addClass context_name
    options =
      url: "/media_resources.json" 
      data:
        ids: [$this.closest(".item_box").data "id"] 
        with: 
          meta_data: 
            meta_context_names: [context_name]
      success: (data)->
        if data.media_resources.length
          $this.html($.tmpl "tmpl/media_resource/thumb_box/meta_data", {meta_data: _.first(data.media_resources).meta_data}, {label: context_label})
    App.MediaResources.fetch options, false

  switch_layout: (e)=>
    do e.preventDefault
    return true if @active_layout == $(e.currentTarget).data("type")
    @el.removeClass @active_layout
    sessionStorage.active_layout = $(e.currentTarget).data "type"
    @active_layout = $(e.currentTarget).data "type"
    @el.addClass @active_layout
    do @switch_context_fetch
  
  switch_context_fetch: =>
    if @active_layout == "list"
      @el.delegate ".meta_data .context[data-name]", "inview", @render_context
    else
      @el.undelegate ".meta_data .context[data-name]", "inview"

  initial_fetch: (new_filter_params, with_filter)=>
    data = JSON.parse JSON.stringify @filter_panel.current_filter
    $.extend data, {sort: App.MediaResources.current_sort}
    $.extend data, new_filter_params if new_filter_params?
    $.extend data, {with_filter: true} if with_filter
    @el.find(".results").html "Lade Inhalte..."
    @ajax.abort() if @ajax?
    @ajax = App.MediaResources.fetch
      url: "/media_resources.json"
      data: data
      success: (data)=>
        @filter_panel.current_filter = data.current_filter
        @filter_panel.update data.filter if data.filter?
        @el.find(".results").html("")
        setupBatch data
        if @filter_panel.current_filter.media_set_id?
          @el.find("#bar h1 small").html @el.find("#bar h1 small").text().replace(/^\d+\s/,"")
          @el.find("#bar h1 small").prepend(data.pagination.total)
        if (data.media_resources.length == 0)
          @el.find(".results").append $.tmpl("tmpl/media_resource/empty_results")

  @fetch: (options, with_default)->
    with_default ?= true
    default_data =
      with: 
        media_type: true
        flags: true
        meta_data: 
          meta_context_names: ["core"]
        image: 
          as: "base64"
    if with_default
      data = if options.data? then $.extend(true, default_data, options.data) else default_data
    else
      data = if options.data? then options.data else {}
    $.ajax
      url: if options.url? then options.url else "/media_resources.json"
      type: if options.type? then options.type else 'GET'
      data: $.extend(data, {format: "json"})
      beforeSend: options.beforeSend
      success: (data)->
        options.success(data)

  @fetch_children: (parent_id, callback, data)->
    default_data = 
      with: 
        children: 
          pagination:
            per_page: 6
          with:
            image:
              as:"base64"
              size:"small"
            meta_data:
              meta_key_names: ["title"]
    data = $.extend default_data, data
    $.ajax
      url: "/media_sets/"+parent_id+".json"
      data: data
      type: "GET"
      success: (data, status, request) -> callback(data)
      error: (request, status, error) -> console.log "ERROR LOADING"

window.App.MediaResources = MediaResourcesController
