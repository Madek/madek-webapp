class MediaResourcesController

  el: "section.media_resources.index"
  
  active_layout: undefined
  
  constructor: ->
    @el = $(@el)
    do @plugin
    @active_layout = if sessionStorage.active_layout? then sessionStorage.active_layout else "grid"
    do @activate_layout
    do @delegate_events
    
  plugin: ->
    new ActionMenu @el
    
  delegate_events: ->
    @el.delegate "#bar .layout a[data-type]", "click", @switch_layout 
    @el.delegate ".page[data-page]", "inview", @render_page

  activate_layout: ->
    @el.addClass @active_layout

  render_page: ->
    $this = $(this)
    next_page = $this.data "page"
    $this.removeAttr "data-page"
    filter_form = $(".filter_content form:first")
    options =
      data:
        page: next_page
      success: (data)->
        display_page(data, $this)
    if filter_form.length and filter_form.data "paginate_using_filter"
      options.url = filter_form.attr('action')
      options.type = filter_form.attr('method')
      $.extend true, options.data, filter_form.serializeObject() 
    else
      options.url = $this.data('url') if $this.data('url')?
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
    return true if @active_layout == $(e.currentTarget).data("type")
    do e.preventDefault
    @el.removeClass @active_layout
    sessionStorage.active_layout = $(e.currentTarget).data "type"
    @active_layout = $(e.currentTarget).data "type"
    @el.addClass @active_layout
    if @active_layout == "list"
      @el.delegate ".meta_data .context[data-name]", "inview", @render_context
    else
      @el.undelegate ".meta_data .context[data-name]", "inview"
      
    
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
      url: options.url
      type: if options.type? then options.type else 'GET'
      data: $.extend(data, {format: "json"})
      success: options.success

  @fetch_children: (parent_id, callback)->
    $.ajax
      url: "/media_sets/"+parent_id+".json"
      data:
        with: 
          children: 
            pagination:
              per_page: 6
            image:
              as:"base64"
              size:"small"
          meta_data:
            meta_key_names: ["title"]
      type: "GET"
      success: (data, status, request) -> callback(data)
      error: (request, status, error) -> console.log "ERROR LOADING"

window.App.MediaResources = MediaResourcesController
