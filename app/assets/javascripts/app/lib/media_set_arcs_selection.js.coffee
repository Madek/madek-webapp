#= require_self
#= require_tree ./media_set_arcs
###

  MediaSetArcsSelection
  
  This script provides functionalities for selecting arcs

###

class MediaSetArcsSelection
  
  constructor: (options)->
    @trigger = options.trigger
    @parentId = options.parentId
    @lightbox = undefined
    do @delegateEvents
  
  delegateEvents: =>
    @trigger.bind "click", (e)=>
      e.preventDefault()
      @openLightbox e.currentTarget
  
  openLightbox: (target)=>
    @lightbox = Dialog.add
      trigger: target
      dialogClass: "media_set_arcs_lightbox"
      content: $.tmpl @template
      closeOnEscape: false
    do @delegateLightboxEvents
    do @load_arcs
  
  delegateLightboxEvents: =>
    @lightbox.find(".cancel").bind "click", =>
      @lightbox.closest(".dialog").dialog "close"
    @lightbox.find(".actions .save:not(.disabled)").live "click", @save
    @lightbox.find(".media_resources .selection input").live "change", @onElementChange

  onElementChange: (e)=> # virtual

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
          onPageLoaded: @pageRenderedCallback
          parameters: @parameters
          tableRowTemplate: "tmpl/media_resource/table_row_with_checkbox"
      
  pageRenderedCallback: (data)=>
    # eneable save button when last page is rendered
    if data.pagination.page == data.pagination.total_pages
      @lightbox.find(".actions .save").removeClass "disabled"

  save: (e)=>
    e.preventDefault()
    @setSavingState e.currentTarget
    do @persist
    # prevent link
    return false

  setSavingState: (button)=>
    # prevent changes
    @lightbox.find("input").attr "disabled", true
    # hide cancel
    @lightbox.find(".cancel").hide()
    # show loading
    $(button).width($(button).width()).html("").append $.tmpl("tmpl/loading_img")
  
  persist: =>
    $.ajax
      url: "/media_resource_arcs.json"
      type: "PUT"
      data: 
        media_resource_arcs: @changedArcs
      success: -> window.location = window.location

window.MediaSetArcsSelection = MediaSetArcsSelection
