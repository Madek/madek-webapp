###

  MediaSetArcsHighlights
  
  This script provides functionalities for selecting arcs and save them as highlights

###
      
class MediaSetArcsHighlights extends MediaSetArcsSelection
  
  constructor: (options)->
    @highlightedResourcesIds = _.map options.highlightedResources.media_resources, (resource)-> resource.id
    @template = "tmpl/media_set/highlights_lightbox"
    @parameters = 
      with:
        meta_data:
          meta_context_names: ["core"]
        image: 
          as: "base64"
          size: "small"
    super

  onElementChange: (e)=> $(e.currentTarget).closest("tr").toggleClass("changed")

  pageRenderedCallback: (data)=>
    # select the media resources from the current rendered page which are highlighted (checkbox = selected)
    highlightedResources = _.filter data.media_resources, (resource)=> _.include(@highlightedResourcesIds, resource.id)
    highlightedResourcesIds = _.map highlightedResources, (resource)-> resource.id
    for id in highlightedResourcesIds
      @lightbox.find("[data-media_resource_id='#{id}']").find("input[type=checkbox]").attr "checked", true
    # put all selected to the top
    for selected in @lightbox.find("table.media_resources input:checked").closest("tr")
      @lightbox.find("table.media_resources tbody").prepend $(selected)
    super

  persist: =>
    @changedArcs = _.map @lightbox.find("table.media_resources tr.changed"), (arc)=>
      child_id: $(arc).tmplItem().data.id
      highlight: $(arc).find(".selection input").is ":checked"
      parent_id: @parentId
    super
        
window.MediaSetArcsHighlights = MediaSetArcsHighlights