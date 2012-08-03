#= require_self
#= require_tree ./media_set_arcs
###

  MediaSetArcsSelection
  
  This script provides functionalities for selecting arcs

###

class MediaSetArcsSelection
  
  constructor: (options)->
    @mode = options.mode
    @trigger = options.trigger
    @parentId = options.parentId
    @highlightedResourcesIds = _.map options.highlightedResources.media_resources, (resource)-> resource.id
    @lightbox = undefined
    do @delegateEvents
  
  delegateEvents: =>
    @trigger.bind "click", (e)=>
      e.preventDefault()
      @openLightbox e.currentTarget
  
  openLightbox: (target)=>
    @lightbox = Dialog.add
      trigger: target
      dialogClass: "media_set_highlights_lightbox"
      content: $.tmpl("tmpl/media_set/highlights_lightbox")
      closeOnEscape: false
    do @delegateLightboxEvents
    do @load_arcs
  
  delegateLightboxEvents: =>
    @lightbox.find(".cancel").bind "click", =>
      @lightbox.closest(".dialog").dialog "close"
    @lightbox.find(".actions .save:not(.disabled)").live "click", @save
    @lightbox.find(".media_resources .selection input").live "change", (e)=>
      $(e.currentTarget).closest("tr").toggleClass("changed")

  load_arcs: =>
    $.ajax
      url: "/media_resource_arcs.json"
      data:
        parent_id: @parentId
      success: (data)=>
        arcs = data.media_resource_arcs
        children_ids = _.map arcs, (arc)-> arc.child_id
        new MediaResourceSelection
          el: @lightbox.find(".media_resource_selection")
          ids: children_ids
          onPageLoaded: @page_rendered_calback
          parameters:
            with:
              meta_data:
                meta_context_names: ["core"]
              image: 
                as: "base64"
                size: "small"
          tableRowTemplate: "tmpl/media_resource/table_row_with_checkbox"
      
  page_rendered_calback: (data)=>
    # select the media resources from the current rendered page which are highlighted (checkbox = selected)
    highlightedResources = _.filter data.media_resources, (resource)=> _.include(@highlightedResourcesIds, resource.id)
    highlightedResourcesIds = _.map highlightedResources, (resource)-> resource.id
    for id in highlightedResourcesIds
      @lightbox.find("[data-media_resource_id='#{id}']").find("input[type=checkbox]").attr "checked", true
    # put all selected to the top
    for selected in @lightbox.find("table.media_resources input:checked").closest("tr")
      @lightbox.find("table.media_resources tbody").prepend $(selected)
    # eneable save button when last page is rendered
    if data.pagination.page == data.pagination.total_pages
      @lightbox.find(".actions .save").removeClass "disabled"

  save: (e)=>
    e.preventDefault()
    # prevent changes
    @lightbox.find("input").attr "disabled", true
    # hide cancel
    @lightbox.find(".cancel").hide()
    # show loading
    button = e.currentTarget
    $(button).width($(button).width()).html("").append $.tmpl("tmpl/loading_img")
    # save changed elements
    do @persist
    # prevent link
    return false
  
  persist: =>
    changed_arcs = _.map @lightbox.find("table.media_resources tr.changed"), (arc)=>
      child_id: $(arc).tmplItem().data.id
      highlight: $(arc).find(".selection input").is ":checked"
      parent_id: @parentId
    $.ajax
      url: "/media_resource_arcs.json"
      type: "PUT"
      data: 
        media_resource_arcs: changed_arcs
      success: -> window.location = window.location

window.MediaSetArcsSelection = MediaSetArcsSelection
