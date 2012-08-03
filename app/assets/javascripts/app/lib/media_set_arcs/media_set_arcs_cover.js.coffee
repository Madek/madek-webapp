###

  MediaSetArcsHighlights
  
  This script provides functionalities for selecting arcs and save them as highlights

###
      
class MediaSetArcsCover extends MediaSetArcsSelection

  constructor: (options)->
    @currentCoverId = options.currentCoverId
    @template = "tmpl/media_set/cover_lightbox"
    @parameters = 
      type: "media_entries"
      with:
        meta_data:
          meta_context_names: ["core"]
        image: 
          as: "base64"
          size: "small"
    super

  onElementChange: (e)=> 
    target = $(e.currentTarget)
    @lightbox.find(".selection input").attr("checked", false)
    target.attr("checked", true)
    # ... todo only one is selected at a time

  pageRenderedCallback: (data)=>
    selected = @lightbox.find("[data-media_resource_id='#{@currentCoverId}']")
    if selected.length
      selected.find("input[type=checkbox]").attr "checked", true
      # put selected at top
      @lightbox.find("table.media_resources tbody").prepend $(selected)
    super

  persist: =>
    @changedArcs = _.map @lightbox.find("table.media_resources .selection input:checked").closest("tr"), (arc)=>
      child_id: $(arc).tmplItem().data.id
      parent_id: @parentId
      cover: true
    super
        
window.MediaSetArcsCover = MediaSetArcsCover