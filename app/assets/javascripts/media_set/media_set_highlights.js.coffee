###

  Media Set Highlights
  
  This script provides functionalities for the media set highlights

###

class MediaSetHighlights
  
  @parent_id
  @children_ids
  @highlighted_resources
  @highlighted_resources_ids
  
  @setup: (data)->
    @setup_listener()
    MediaSetHighlights.highlighted_resources = data.media_resources
    MediaSetHighlights.highlighted_resources_ids = _.map data.media_resources, (resource)-> resource.id
    @render()
    setTimeout ->
      MediaSetHighlights.setup_positioning()
    , 100
  
  @setup_listener: ->
    $(".open_media_set_highlights_lightbox").live "click", (event)->
      event.preventDefault()
      MediaSetHighlights.open_lightbox event.currentTarget
    $("#media_set_highlights_lightbox .cancel").live "click", ->
      $("#media_set_highlights_lightbox").closest(".dialog").dialog "close"
    $("#media_set_highlights_lightbox .media_resources .selection input").live "change", ->
      $(this).closest("tr").toggleClass("changed")
    $("#media_set_highlights_lightbox .actions .save:not(.disabled)").live "click", MediaSetHighlights.save
  
  @render: ->
    for media_resource in MediaSetHighlights.highlighted_resources
      meta_data = MetaDatum.flatten media_resource.meta_data
      media_resource = $.extend media_resource, meta_data
      $("#media_set_highlights .inner").append $.tmpl "tmpl/media_resource/highlight", media_resource 
  
  @setup_positioning: ->
    # set the width of the inner container
    max_width = _.reduce $("#media_set_highlights .inner .highlight"), (mem, el)->
        mem+$(el).outerWidth()
      , 0
    $("#media_set_highlights .inner").outerWidth max_width+$("#media_set_highlights .inner").outerWidth()-$("#media_set_highlights .inner").width() + 20 # 20 as security spacer
    # scroll to the center
    $("#media_set_highlights .container").scrollLeft(($("#media_set_highlights .inner").outerWidth()-$("#media_set_highlights .container").outerWidth())/2)
  
  @open_lightbox: (target)->
    container = Dialog.add
      trigger: target
      dialogClass: "media_set_highlights_lightbox"
      content: $.tmpl("tmpl/media_set/highlights_lightbox")
      closeOnEscape: false
    @load_arcs $("#media_set_highlights").data("parent_id"), container
  
  @load_arcs: (parent_id, container)->
    MediaSetHighlights.parent_id = parent_id
    $.ajax
      url: "/media_resource_arcs.json"
      data:
        parent_id: parent_id
      success: (data)->
        arcs = data.media_resource_arcs
        MediaSetHighlights.children_ids = _.map arcs, (arc)-> arc.child_id
        # create a media resource selection
        MediaResourceSelection.setup 
          container: $(container).find(".media_resource_selection")
          media_resource_ids: MediaSetHighlights.children_ids
          callback: MediaSetHighlights.page_rendered_calback
          contexts: ["core"]
          table_row_template: "tmpl/media_resource/table_row_with_checkbox"  
      
  @page_rendered_calback: (data)->
    # select the media resources from the current rendered page which are highlighted (checkbox = selected)
    highlighted_resources = _.filter data.media_resources, (resource)-> _.include(MediaSetHighlights.highlighted_resources_ids, resource.id)
    highlighted_resources_ids = _.map highlighted_resources, (resource)-> resource.id
    for id in highlighted_resources_ids
      $("[data-media_resource_id='#{id}']").find("input[type=checkbox]").attr "checked", true
    # put all selected to the top
    for selected in $("#media_set_highlights_lightbox table.media_resources input:checked").closest("tr")
      $("#media_set_highlights_lightbox table.media_resources tbody").prepend $(selected)
    # render table
    MediaResourceSelection.render_table $("#media_set_highlights_lightbox")
    # eneable save button when last page is rendered
    if data.pagination.page == data.pagination.total_pages
      $("#media_set_highlights_lightbox .actions .save").removeClass "disabled" 

  @save: (event)->
    event.preventDefault()
    container = $("#media_set_highlights_lightbox")
    # prevent changes
    $(container).find("input").attr "disabled", true
    # hide cancel
    $(container).find(".cancel").hide()
    # show loading
    button = event.currentTarget
    $(button).width($(button).width()).html("").append("<img src='/assets/loading.gif'/>").addClass("loading")
    # save changed elements
    MediaSetHighlights.persist()
    # prevent link
    return false
  
  @persist: ->
    changed_arcs = _.map $("#media_set_highlights_lightbox table.media_resources tr.changed"), (arc)->
      child_id: $(arc).tmplItem().data.id
      highlight: $(arc).find(".selection input").is ":checked"
      parent_id: MediaSetHighlights.parent_id
    console.log changed_arcs
    $.ajax
      url: "/media_resource_arcs.json"
      type: "PUT"
      data: 
        media_resource_arcs: changed_arcs
      success: -> window.location = window.location
        
window.MediaSetHighlights = MediaSetHighlights