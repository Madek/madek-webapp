class MediaResourcesController

  el: "section.media_resources.index"
  
  active_layout: -> if sessionStorage.active_layout? then sessionStorage.active_layout else "grid"
  
  constructor: ->
    @el = $(@el)
    do @render
    do @activate_layout
    do @delegate_events
    
  render: ->
    # we only render the layout controller
    @el.find("#bar .layout").prepend($.tmpl "app/views/media_resources/_layout_controller")
    
  delegate_events: ->
    @el.delegate "#bar .layout a", "click", @switch_layout 
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

  switch_layout: (e)=>
    do e.preventDefault
    @el.removeClass @active_layout
    sessionStorage.active_layout = $(e.currentTarget).data "type"
    @el.addClass @active_layout
    
  @fetch: (options)->
    default_data =
      format: 'json'
      with: 
        media_type: true
        flags: true
        meta_data: 
          meta_context_names: ["core"]
        image: 
          as: "base64"
    $.ajax
      url: options.url
      type: if options.type? then options.type else 'GET'
      data: if options.data? then $.extend(true, default_data, options.data) else default_data
      success: options.success

window.App.MediaResources = MediaResourcesController
