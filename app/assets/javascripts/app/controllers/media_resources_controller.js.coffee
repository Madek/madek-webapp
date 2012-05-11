class MediaResourcesController

  el: "section#content_body"
  
  active:
    layout: if sessionStorage.active? and sessionStorage.active.layout? then sessionStorage.active.layout else "grid"
  
  constructor: ->
    @el = $(@el)
    do @render
    do @delegate_events
    
  render: ->
    # we only render the display controller
    @layout_controller = @el.find("#bar .layout").prepend($.tmpl "app/views/media_resources/_layout_controller")
    @layout_controller.find("[data-type=#{@active.layout}]").addClass("active")    
    
  delegate_events: ->
    @el.delegate "#bar .layout a", "click", @switch_layout 
    @el.delegate ".page[data-page]", "inview", @render_page

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
      params = {}
      $.each filter_form.serializeArray(), (i, field)-> params[field.name] = field.value
      options.url = filter_form.attr('action')
      options.type = filter_form.attr('method')
      $.extend true, options.data, params 
    else
      options.url = $this.data('url') if $this.data('url')?
    App.MediaResources.fetch options

  switch_layout: (e)->
    do e.preventDefault
    # TODO sessionStorage.active.layout
    console.log $(this)
    
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
